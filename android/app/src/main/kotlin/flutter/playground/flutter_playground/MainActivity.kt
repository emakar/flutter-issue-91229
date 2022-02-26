package flutter.playground.flutter_playground

import com.yandex.mapkit.MapKitFactory
import com.yandex.mapkit.map.MapType
import com.yandex.mapkit.mapview.MapTexture
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.view.TextureRegistry

private class MapSurfaceTexture(
    val flutterSurfaceTexture: TextureRegistry.SurfaceTextureEntry,
    val map: MapTexture,
)

class MainActivity: FlutterActivity() {

    private var api: MapTextureApi? = null
    private var engine: FlutterEngine? = null
    private var texture: MapSurfaceTexture? = null
    private var started = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val api = MapTextureApi(flutterEngine.dartExecutor.binaryMessenger)

        this.api = api
        this.engine = flutterEngine

        api.setRequestHandler { message ->
            when (message) {
                is MapTextureMessage.Initialize -> {
                    if (texture != null) {
                        disposeMap(texture!!)
                    }
                    val mapSurfaceTexture = initMap(message.width, message.height)
                    val id = mapSurfaceTexture.flutterSurfaceTexture.id()
                    texture = mapSurfaceTexture
                    id.toString()
                }
                is MapTextureMessage.Configure -> {
                    texture!!.map.onTextureSizeChanged(message.width.toInt(), message.height.toInt())
                    "configure ok"
                }
                is MapTextureMessage.Dispose -> {
                    disposeMap(texture!!)
                    texture = null
                    "dispose ok"
                }
            }
        }
    }

    override fun onStart() {
        super.onStart()
        start()
    }

    override fun onStop() {
        super.onStop()
        stop()
    }

    override fun onDestroy() {
        disposeMap(texture!!)
        super.onDestroy()
    }

    private fun initMap(width: Float, height: Float): MapSurfaceTexture {
        val flutterSurfaceTexture = engine!!.renderer.createSurfaceTexture()
        val mapView = MapTexture(context, width.toInt(), height.toInt())
        mapView.setTexture(flutterSurfaceTexture.surfaceTexture(), width.toInt(), height.toInt())

        System.gc()

        return MapSurfaceTexture(flutterSurfaceTexture, mapView).also {
            start()
        }
    }

    private fun start() {
        val texture = texture ?: return
        if (started) return
        started = true
        MapKitFactory.getInstance().onStart()
        texture.map.onStart()
        texture.map.map.mapType = MapType.VECTOR_MAP
    }

    private fun stop() {
        val texture = texture ?: return
        if (!started) return
        started = false
        MapKitFactory.getInstance().onStop()
        texture.map.onStop()
    }

    private fun disposeMap(mapSurfaceTexture: MapSurfaceTexture) {
        mapSurfaceTexture.map.removeTexture()
        mapSurfaceTexture.flutterSurfaceTexture.release()
        stop()
    }
}
