package flutter.playground.flutter_playground

import android.content.res.Resources
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StringCodec
import org.json.JSONObject

val density = Resources.getSystem().displayMetrics.density

val Int.px: Float
    get() = this.toFloat() * density

val Double.px: Float
    get() = this.toFloat() * density

val Float.px: Float
    get() = this * density

sealed class MapTextureMessage {

    class Initialize(
        val width: Float,
        val height: Float,
    ) : MapTextureMessage()

    class Configure(
        val mapId: Long,
        val width: Float,
        val height: Float,
    ) : MapTextureMessage()

    class Dispose(
        val mapId: Long,
    ) : MapTextureMessage()
}

typealias RequestHandler = (MapTextureMessage) -> String

class MapTextureApi(messenger: BinaryMessenger) {

    private val channel = BasicMessageChannel(messenger, "map_view_factory", StringCodec.INSTANCE)

    fun setRequestHandler(handler: RequestHandler?) {
        if (handler == null) {
            channel.setMessageHandler(null)
            return
        }
        channel.setMessageHandler { message, reply ->
            if (message == null) {
                reply.reply(null)
                return@setMessageHandler
            }
            val messageJson = JSONObject(message)
            val type = messageJson.optString("type")
            val data = messageJson.optString("data")
            val msg = toMessage(type, data)
            if (msg != null) {
                reply.reply(handler(msg))
            } else {
                reply.reply(null)
            }
        }
    }
}

private fun toMessage(type: String?, data: String?): MapTextureMessage? {
    if (type == null || data == null) return null
    return when (type) {
        "initialize" -> {
            val msg = JSONObject(data)
            return MapTextureMessage.Initialize(msg.getDouble("width").px, msg.getDouble("height").px)
        }
        "configure" -> {
            val msg = JSONObject(data)
            return MapTextureMessage.Configure(
                msg.getLong("mapId"),
                msg.getDouble("width").px,
                msg.getDouble("height").px,
            )
        }
        "dispose" -> {
            val msg = JSONObject(data)
            return MapTextureMessage.Dispose(msg.getLong("mapId"))
        }
        else -> null
    }
}
