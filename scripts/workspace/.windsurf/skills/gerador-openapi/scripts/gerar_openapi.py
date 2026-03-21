#!/usr/bin/env python3
"""
Gerador de documentação OpenAPI 3.0 para microsserviços Java/Spring Boot.
Extrai endpoints, schemas e operações do código fonte.
"""

import argparse
import os
import re
import sys
import yaml
from pathlib import Path
from typing import Any


def encontrar_controllers(projeto_path: str) -> list[str]:
    """Encontra arquivos de controller no projeto."""
    controllers = []
    padrao = re.compile(r'.*Controller\.java$', re.IGNORECASE)
    
    for root, _, files in os.walk(projeto_path):
        for arquivo in files:
            if padrao.match(arquivo):
                controllers.append(os.path.join(root, arquivo))
    
    return controllers


def extrair_endpoints(arquivo_controller: str) -> list[dict[str, Any]]:
    """Extrai endpoints de um arquivo controller."""
    endpoints = []
    
    with open(arquivo_controller, 'r', encoding='utf-8') as f:
        conteudo = f.read()
    
    # Extrair classe controller
    classe_match = re.search(r'@RestController\s*(?:@RequestMapping\("([^"]+)"\))?\s*class\s+(\w+)', conteudo)
    base_path = classe_match.group(1) if classe_match and classe_match.group(1) else ""
    classe_nome = classe_match.group(2) if classe_match else "Unknown"
    
    # Padrões de anotações de endpoint
    padroes = [
        (r'@GetMapping\("(.*?)"\)', 'get'),
        (r'@PostMapping\("(.*?)"\)', 'post'),
        (r'@PutMapping\("(.*?)"\)', 'put'),
        (r'@DeleteMapping\("(.*?)"\)', 'delete'),
        (r'@PatchMapping\("(.*?)"\)', 'patch'),
        (r'@RequestMapping\("(.*?)"\)', 'get'),
        (r'@GetMapping\(value\s*=\s*"(.*?)"\)', 'get'),
        (r'@PostMapping\(value\s*=\s*"(.*?)"\)', 'post'),
    ]
    
    # Encontrar métodos
    metodos_encontrados = re.finditer(
        r'@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestMapping)\s*(?:\([^)]*\))?\s*public\s+\w+(?:<[^>]+>)?\s+(\w+)\s*\([^)]*\)',
        conteudo
    )
    
    for match in metodos_encontrados:
        anotacao = match.group(1)
        nome_metodo = match.group(2)
        
        # Extrair path do método
        path_match = re.search(rf'@{anotacao}\s*(?:\(.*?value\s*=\s*)?["\']([^"\']+)["\']', conteudo[match.start():match.end() + 200])
        path = path_match.group(1) if path_match else ""
        
        # Determinar método HTTP
        http_method = 'get'
        if 'PostMapping' in anotacao:
            http_method = 'post'
        elif 'PutMapping' in anotacao:
            http_method = 'put'
        elif 'DeleteMapping' in anotacao:
            http_method = 'delete'
        elif 'PatchMapping' in anotacao:
            http_method = 'patch'
        
        full_path = f"{base_path}{path}".replace("//", "/")
        
        endpoints.append({
            'path': full_path,
            'method': http_method,
            'operationId': nome_metodo,
            'tags': [classe_nome.replace('Controller', '')],
            'summary': nome_metodo,
        })
    
    return endpoints


def gerar_openapi(projeto: str, projeto_path: str, output_dir: str) -> dict[str, Any]:
    """Gera a especificação OpenAPI completa."""
    
    info = {
        'title': projeto.replace('-', ' ').replace('_', ' ').title(),
        'version': '1.0.0',
        'description': f'API do microsserviço {projeto}'
    }
    
    openapi_spec = {
        'openapi': '3.0.3',
        'info': info,
        'paths': {},
        'components': {
            'schemas': {},
            'securitySchemes': {
                'bearerAuth': {
                    'type': 'http',
                    'scheme': 'bearer',
                    'bearerFormat': 'JWT'
                }
            }
        },
        'security': [{'bearerAuth': []}]
    }
    
    controllers = encontrar_controllers(projeto_path)
    
    for controller in controllers:
        endpoints = extrair_endpoints(controller)
        for endpoint in endpoints:
            path = endpoint['path']
            if path not in openapi_spec['paths']:
                openapi_spec['paths'][path] = {}
            
            openapi_spec['paths'][path][endpoint['method']] = {
                'tags': endpoint['tags'],
                'summary': endpoint['summary'],
                'operationId': endpoint['operationId'],
                'responses': {
                    '200': {
                        'description': 'Sucesso'
                    },
                    '400': {
                        'description': 'Requisição inválida'
                    },
                    '401': {
                        'description': 'Não autorizado'
                    },
                    '500': {
                        'description': 'Erro interno'
                    }
                }
            }
    
    return openapi_spec


def main():
    parser = argparse.ArgumentParser(description='Gera documentação OpenAPI para microsserviços')
    parser.add_argument('--projeto', required=True, help='Nome do projeto/microsserviço')
    parser.add_argument('--output', default='docs/apis', help='Diretório de saída')
    parser.add_argument('--projeto-path', help='Caminho do código fonte (padrão: projetos/<projeto>)')
    
    args = parser.parse_args()
    
    projeto_path = args.projeto_path or f"projetos/{args.projeto}"
    
    if not os.path.exists(projeto_path):
        print(f"Erro: Projeto não encontrado em {projeto_path}")
        sys.exit(1)
    
    output_dir = os.path.join(args.output, args.projeto)
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"Gerando OpenAPI para {args.projeto}...")
    
    spec = gerar_openapi(args.projeto, projeto_path, output_dir)
    
    output_file = os.path.join(output_dir, 'openapi.yaml')
    with open(output_file, 'w', encoding='utf-8') as f:
        yaml.dump(spec, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
    
    print(f"Spec gerada em: {output_file}")
    print(f"Total de endpoints: {sum(len(p) for p in spec['paths'].values())}")


if __name__ == '__main__':
    main()
