allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Suppress obsolete `-source`/`-target` warnings from Java compiler
// by disabling the `options` lint. This keeps the Gradle output cleaner
// while underlying plugins or third-party modules may still use older
// source/target values.
// Apply to all projects to ensure coverage (some plugins configure tasks later)
allprojects {
    tasks.matching { it is org.gradle.api.tasks.compile.JavaCompile }.configureEach {
        (this as org.gradle.api.tasks.compile.JavaCompile).options.compilerArgs.apply {
            add("-Xlint:-options")
            add("-Xlint:-deprecation")
            add("-nowarn")
        }
    }

    // Also silence Kotlin compiler warnings which can emit similar deprecation notes.
    tasks.matching { it.javaClass.name == "org.jetbrains.kotlin.gradle.tasks.KotlinCompile" }
        .configureEach {
            try {
                val kotlinCompile = this
                val kotlinOptions = kotlinCompile.javaClass.getMethod("getKotlinOptions").invoke(kotlinCompile)
                val freeArgsProp = kotlinOptions.javaClass.getDeclaredField("freeCompilerArgs")
                freeArgsProp.isAccessible = true
                val current = freeArgsProp.get(kotlinOptions) as? MutableList<String>
                if (current != null) {
                    if (!current.contains("-nowarn")) current.add("-nowarn")
                }
            } catch (ignored: Exception) {
                // Fall back silently if reflection access fails on some Gradle/Kotlin versions
            }
        }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
