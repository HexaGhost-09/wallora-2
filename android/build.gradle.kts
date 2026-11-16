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
    afterEvaluate {
        // Align older Flutter plugin modules with the app's Android API level.
        // blurhash 1.2.0 declares API 31, but its AndroidX AAR dependencies
        // require API 34 or later, so AAR metadata validation otherwise fails.
        if (name != "app") {
            val androidExtension = extensions.findByName("android")
            if (androidExtension != null) {
                val setter = androidExtension.javaClass.methods.firstOrNull {
                    it.name == "setCompileSdkVersion" &&
                        it.parameterCount == 1 &&
                        it.parameterTypes[0] == Int::class.javaPrimitiveType
                }
                setter?.invoke(androidExtension, 37)
            }
        }
    }

    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    project.configurations.all {
        resolutionStrategy {
            force("androidx.browser:browser:1.8.0")
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.core:core:1.13.1")
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
