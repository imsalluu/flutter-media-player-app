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
    project.evaluationDependsOn(":app")
}

subprojects {
    afterEvaluate {
        val isAndroid = plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")
        if (isAndroid) {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                if (namespace.isNullOrEmpty()) {
                    namespace = when (project.name) {
                        "on_audio_query_android" -> "com.lucasjosino.on_audio_query"
                        else -> project.group.toString().takeIf { it.isNotBlank() && it != "unspecified" }
                            ?: "com.example.${project.name.replace('-', '_').replace('.', '_')}"
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

