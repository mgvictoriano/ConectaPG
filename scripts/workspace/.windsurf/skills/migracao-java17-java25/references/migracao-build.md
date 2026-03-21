# Migração de Build: Maven → Gradle

## Visão Geral

O stack legado usa Maven (`pom.xml`) com Spring Boot 2.4 e Java 17. O stack moderno usa Gradle com Spring Boot 4 e Java 25.

## Estrutura de Arquivos Gradle

Criar três arquivos na raiz do projeto:

### `build.gradle`

```groovy
plugins {
    id 'java'
    id 'maven-publish'
    id 'pl.allegro.tech.build.axion-release' version '1.21.0'
    id 'org.springframework.boot' version '4.0.2'
    id 'io.spring.dependency-management' version '1.1.7'
    id 'org.graalvm.buildtools.native' version '0.11.1'
    id 'org.sonarqube' version '6.2.0.5505'
    id 'jacoco'
}

group = 'ai.attus'
version = scmVersion.version

scmVersion {
    versionIncrementer 'incrementMinor'
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

repositories {
    mavenLocal()
    mavenCentral()
    maven {
        name = "Reposilite"
        url = uri("https://reposilite.dev.attus.ai/master")
        credentials {
            username = project.findProperty("reposiliteUsername") ?: System.getenv("REPOSILITE_USERNAME")
            password = project.findProperty("reposilitePassword") ?: System.getenv("REPOSILITE_PASSWORD")
        }
    }
}

dependencyManagement {
    imports {
        mavenBom("ai.attus:attus-platform-bom:${project.attusPlatformVersion}")
    }
}

dependencies {
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    annotationProcessor 'org.springframework.boot:spring-boot-configuration-processor'

    // Bibliotecas Attus (versões gerenciadas pelo BOM — NUNCA hardcodar versões aqui)
    implementation 'ai.attus:lib-parametro'
    implementation 'ai.attus:lib-core'
    implementation 'ai.attus:lib-auditoria'
    implementation 'ai.attus:lib-starter'
    implementation 'ai.attus:lib-cache'
    implementation 'ai.attus:lib-database'
    implementation 'ai.attus:lib-security'
    implementation 'ai.attus:lib-utils'
    implementation 'ai.attus:lib-messageria'

    // Spring Boot starters
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.security:spring-security-oauth2-core'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-data-redis'
    implementation 'org.springframework.boot:spring-boot-starter-data-rest'
    implementation 'org.springframework.boot:spring-boot-starter-kafka'
    implementation 'org.springframework.cloud:spring-cloud-starter-openfeign'

    // Micrometer/Prometheus
    implementation 'io.micrometer:micrometer-registry-prometheus'

    // Database drivers
    runtimeOnly 'com.h2database:h2'
    runtimeOnly 'org.postgresql:postgresql'
    runtimeOnly 'com.oracle.database.jdbc:ojdbc11'

    // Testes
    testImplementation 'org.springframework.boot:spring-boot-webmvc-test'
    testImplementation 'ai.attus:lib-test'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
    testImplementation 'org.springframework.cloud:spring-cloud-contract-wiremock'
    testImplementation 'org.springframework.kafka:spring-kafka-test'
    testCompileOnly 'org.projectlombok:lombok'
    testAnnotationProcessor 'org.projectlombok:lombok'
}

tasks.withType(JavaCompile).configureEach {
    options.fork = true
}

tasks.named('compileTestJava') {
    dependsOn tasks.named('jar')
}

tasks.named('processTestAot') {
    enabled = false
}

jacoco {
    toolVersion = "0.8.13"
}

test {
    useJUnitPlatform()
    finalizedBy jacocoTestReport
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
    }
}

sonarqube {
    properties {
        property "sonar.host.url", project.findProperty("sonarHostUrl") ?: ""
        property "sonar.token", project.findProperty("sonarToken") ?: ""
        property "sonar.coverage.jacoco.xmlReportPaths", layout.buildDirectory.file("reports/jacoco/test/jacocoTestReport.xml").get().asFile.absolutePath
        property "sonar.qualitygate.wait", "true"
        property "sonar.cache.enabled", "true"
        property "sonar.java.batch.size", "8"
    }
}

jar {
    archiveBaseName.set("app")
    archiveVersion.set("")
}

bootJar {
    archiveFileName = "app.jar"
}

springBoot {
    buildInfo()
}
```

### `settings.gradle`

```groovy
rootProject.name = '<nome-do-servico>'

def localLibraries = [
        '../lib-test',
        '../lib-security',
        '../lib-auditoria',
        '../bibliotecas/core/lib-utils'
]

println "Checking for local libraries to include..."
localLibraries.each { path ->
    def libraryDir = file(path)
    if (libraryDir.exists() && libraryDir.isDirectory()) {
        println "Including local build from: ${libraryDir.canonicalPath}"
        includeBuild(libraryDir)
    } else {
        println "Skipping local build (not found): ${libraryDir.canonicalPath}"
    }
}
```

### `gradle.properties`

```properties
attusPlatformVersion=1.216.0
org.gradle.caching=true
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g
```

## Mapeamento de Dependências Maven → Gradle

| Maven (pom.xml) | Gradle (build.gradle) |
|---|---|
| `<parent>` spring-boot-starter-parent | Plugin `org.springframework.boot` |
| `<dependencyManagement>` spring-cloud-dependencies | `mavenBom("ai.attus:attus-platform-bom:...")` |
| `<dependency>` com.attornatus:core | Múltiplas libs `ai.attus:lib-*` |
| `<dependency>` spring-security-oauth2-autoconfigure | `spring-security-oauth2-core` |
| `<dependency>` ojdbc8 | `ojdbc11` |
| `<dependency>` h2 1.4.200 | `h2` (versão gerenciada pelo BOM) |
| `<dependency>` jaxb-api + jaxb-impl | **REMOVIDO** (não necessário no Jakarta EE) |
| `<dependency>` awaitility-proxy | **REMOVIDO** |
| `<dependency>` spring-instrument (test) | **REMOVIDO** (não necessário com Spring Boot 4) |
| `<dependency>` jetbrains:annotations | **REMOVIDO** |
| maven-surefire-plugin com spring-instrument agent | `tasks.withType(JavaCompile)` com fork |
| jacoco-maven-plugin | Plugin `jacoco` nativo do Gradle |
| maven-compiler-plugin | `java.toolchain.languageVersion` |

## Gradle Wrapper

Instalar o wrapper executando:

```bash
gradle wrapper --gradle-version=9.1.0
```

> **Recomendação**: Usar a mesma versão do Gradle definida nos projetos `admin` e `auditoria` (atualmente **9.1.0**). Isso garante consistência de comportamento e evita problemas de compatibilidade entre projetos.

Isso cria:
- `gradlew` (script Unix)
- `gradlew.bat` (script Windows)
- `gradle/wrapper/gradle-wrapper.jar`
- `gradle/wrapper/gradle-wrapper.properties`

## Centralização de Versões no BOM

**REGRA:** Nenhuma dependência no `build.gradle` de um microsserviço ou lib pode ter versão hardcoded. TODAS as versões devem estar centralizadas no `attus-platform-bom`.

### Exceção

Versões de **plugins Gradle** (bloco `plugins {}`) podem ter versão inline — plugins não são gerenciados pelo BOM do Maven/Gradle dependency management.

### Errado ✗

```groovy
dependencies {
    implementation 'org.jsoup:jsoup:1.22.1'                          // ← versão hardcoded
    implementation 'commons-io:commons-io:2.19.0'                    // ← versão hardcoded
    implementation 'org.xhtmlrenderer:flying-saucer-pdf:9.13.3'      // ← versão hardcoded
    implementation 'com.itextpdf:itextpdf:5.5.13.5'                  // ← versão hardcoded
    testImplementation 'org.glassfish.jaxb:jaxb-runtime:2.3.3'       // ← versão hardcoded
}
```

### Correto ✓

```groovy
// build.gradle do microsserviço — sem versões
dependencies {
    implementation 'org.jsoup:jsoup'
    implementation 'commons-io:commons-io'
    implementation 'org.xhtmlrenderer:flying-saucer-pdf'
    implementation 'com.itextpdf:itextpdf'
    testImplementation 'org.glassfish.jaxb:jaxb-runtime'
}
```

```groovy
// attus-platform-bom/build.gradle — versões centralizadas
constraints {
    api("org.jsoup:jsoup:${project.jsoupVersion}")
    api("org.xhtmlrenderer:flying-saucer-pdf:${project.flyingSaucerVersion}")
    api("com.itextpdf:itextpdf:${project.itextpdfVersion}")
    api("org.glassfish.jaxb:jaxb-runtime:${project.jaxbVersion}")
    // ... demais dependências
}
```

```properties
# attus-platform-bom/gradle.properties — valores das versões
jsoupVersion=1.22.1
flyingSaucerVersion=9.13.3
itextpdfVersion=5.5.13.5
jaxbVersion=2.3.3
```

### Procedimento durante a Migração

1. Listar todas as dependências do `pom.xml` legado que possuem `<version>` explícita
2. Verificar se já existe no `attus-platform-bom` (constraints ou BOMs importados)
3. Se **não existe** → adicionar ao BOM (`constraints` + `gradle.properties`)
4. Se **já existe** com versão diferente → verificar compatibilidade e atualizar o BOM se necessário
5. No `build.gradle` do microsserviço, declarar a dependência **sem versão**

> **Nota:** Dependências transitivas já gerenciadas pelos BOMs importados (Spring Boot, Spring Cloud, OTel) não precisam ser adicionadas ao `constraints` — o `spring-boot-dependencies` e `spring-cloud-dependencies` já as gerenciam.

## Configurações Importantes do Gradle

- `processTestAot.enabled = false` — desabilita AOT para testes (evita problemas com mocks)
- `compileTestJava.dependsOn jar` — garante que o jar está disponível para testes
- `options.fork = true` — compila em processo separado (necessário para Java 25)
