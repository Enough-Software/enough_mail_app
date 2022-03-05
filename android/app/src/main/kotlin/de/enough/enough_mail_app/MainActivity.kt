package de.enough.enough_mail_app

//import android.content.ContentProviderClient
import android.content.Intent
import android.os.Bundle
import android.net.Uri
import android.provider.OpenableColumns
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

import java.io.File

class MainActivity: FlutterFragmentActivity() {
    private var sharedDataMap : Map<String, Any>? = null

    private val _channel = "app.channel.shared.data"

    override fun onCreate(savedInstanceState: Bundle?) {
        checkForShareIntent(intent)
        super.onCreate(savedInstanceState)
    }
    
    override fun onNewIntent(newIntent: Intent) {
        //println("maily onNewIntent: $newIntent")
        checkForShareIntent(newIntent)
        super.onNewIntent(newIntent)
    }

    private fun checkForShareIntent(shareIntent: Intent) {
        val action = shareIntent.action
        val type = shareIntent.type

        //println("checkForShareIntent: $shareIntent")
        if (action == Intent.ACTION_SEND || action == Intent.ACTION_SEND_MULTIPLE || action == Intent.ACTION_SENDTO || action == Intent.ACTION_VIEW) {
            extractShareData(shareIntent, action, type)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel)

        channel.setMethodCallHandler { call, result ->
            if (call.method == "getSharedData") {
                result.success(sharedDataMap)
                sharedDataMap = null
            }
        }
    }

    private fun extractShareData(shareIntent: Intent, action: String, type: String?) {
        //println("extract share data from $shareIntent")
        val result: MutableMap<String,Any> = HashMap<String, Any>()
        if (type != null) {
            result["mimeType"] = type
        }
        if (action == Intent.ACTION_SEND_MULTIPLE) {
            val uris = shareIntent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
            if (uris == null) {
                result["length"] = 0
            } else {
                val count = uris.count()
                result["length"] = count
                for (i in 0 until count) {
                    val uri = uris[i]
                    result["data.$i"] = loadUriData(uri)
                    result["name.$i"] = getFileName(uri)
                    result["type.$i"] = getMimeType(uri)
                }
            }
        } else if (action == Intent.ACTION_SENDTO || action == Intent.ACTION_VIEW) {
            //println("$action: with data ${shareIntent.data} dataString ${shareIntent.dataString}")
            val dataString = shareIntent.dataString
            if (dataString != null) {
                result["text"] = dataString 
            }
        } else {
            val uri = shareIntent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            //println("got uri $uri")
            if (uri != null) {
                result["length"] = 1
                result["data.0"] = loadUriData(uri)
                result["name.0"] = getFileName(uri)
                result["type.0"] = getMimeType(uri)
            } else {
                val dataString = shareIntent.dataString
                if (dataString != null) {
                    result["text"] = dataString
                } else if (shareIntent.hasExtra("android.intent.extra.TEXT")){
                    val text = shareIntent.getStringExtra("android.intent.extra.TEXT")
                    if (text != null) {
                        result["text"] = text
                    }
                    val  subject = shareIntent.getStringExtra("android.intent.extra.SUBJECT")
                    if (subject != null) {
                        result["subject"] = subject
                    }
                }
            }
        }
        //println("sharedData: $result")
        sharedDataMap = result
    }

    private fun getMimeType(uri: Uri): String {
        return  contentResolver.getType(uri) ?: "null"
    }

    private fun getFileName(uri: Uri): String {
        val filename = contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            cursor.moveToFirst()
            cursor.getString(nameIndex)
        }
        if (filename != null) {
            return filename
        }
        val path = uri.path
        if (path != null) {
            return File(path).name
        }
        return "null"
    }

    private fun loadUriData(uri: Uri): ByteArray {
        val inputStream = contentResolver.openInputStream(uri)!!
        val bytes = inputStream.readBytes()        
        inputStream.close()
        return bytes
    }
}
