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
    val configureNamespace: (Project) -> Unit = { proj ->
        if (proj.plugins.hasPlugin("com.android.application") || proj.plugins.hasPlugin("com.android.library")) {
            proj.extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                if (namespace.isNullOrEmpty()) {
                    namespace = when (proj.name) {
                        "on_audio_query_android" -> "com.lucasjosino.on_audio_query"
                        else -> proj.group.toString().takeIf { it.isNotBlank() && it != "unspecified" }
                            ?: "com.example.${proj.name.replace('-', '_').replace('.', '_')}"
                    }
                }
            }
        }
    }

    if (project.state.executed) {
        configureNamespace(project)
    } else {
        project.afterEvaluate { configureNamespace(this) }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

