allprojects {
    repositories {
        google()
        mavenCentral()
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
    plugins.withId("com.android.library") {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
            if (namespace.isNullOrBlank()) {
                namespace = when (project.name) {
                    "on_audio_query_android" -> "com.lucasjosino.on_audio_query"
                    else -> project.group.toString().takeIf { it.isNotBlank() && it != "unspecified" }
                        ?: "com.example.${project.name.replace('-', '_').replace('.', '_')}"
                }
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
            if (namespace.isNullOrBlank()) {
                namespace = project.group.toString().takeIf { it.isNotBlank() && it != "unspecified" }
                    ?: "com.example.${project.name.replace('-', '_').replace('.', '_')}"
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

