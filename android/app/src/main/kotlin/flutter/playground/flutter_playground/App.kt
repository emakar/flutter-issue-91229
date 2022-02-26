package flutter.playground.flutter_playground

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class App : Application() {

    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("62ce515d-7721-4eb2-a782-be462fc1d5cc")
        MapKitFactory.initialize(this)
    }
}
