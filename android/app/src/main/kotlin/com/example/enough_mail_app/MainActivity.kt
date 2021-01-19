package com.example.enough_mail_app

import android.content.ContentProviderClient
import android.content.Intent
import android.os.Bundle
import android.net.Uri
import android.provider.OpenableColumns
import androidx.annotation.NonNull

import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    var sharedData : String? = null
    private val CHANNEL = "app.channel.shared.data"

    override fun onCreate(savedInstanceState: Bundle?) {
        checkForShareIntent(intent)
        super.onCreate(savedInstanceState)
    }
    
    override fun onNewIntent(newIntent: Intent) {
        checkForShareIntent(newIntent)
        super.onNewIntent(newIntent)
    }

    private fun checkForShareIntent(shareIntent: Intent) {
        if (shareIntent != null) {
            val action = shareIntent.action
            val type = shareIntent.type

            //println("checkForShareIntent: $shareIntent")
            if (action == Intent.ACTION_SEND || action == Intent.ACTION_SEND_MULTIPLE || action == Intent.ACTION_SENDTO || action == Intent.ACTION_VIEW) {
                extractShareData(shareIntent, action, type)
            } 
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            if (call.method == "getSharedData") {
                result.success(sharedData)
                sharedData = null;
            }
        }
    }

    private fun extractShareData(shareIntent: Intent, action: String, type: String?) {
        //println("extract share data from $shareIntent")
        var uriText : String?
        if (action == Intent.ACTION_SEND_MULTIPLE) {
            var uris = shareIntent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM);
            //println("got uris $uris")
            var strings = uris.map { "<<$it>>" }
//            val mimeType: String? = shareIntent.data?.let { returnUri ->
//                contentResolver.getType(returnUri)
//            }
//            println('got mime')
            // val client: ContentProviderClient? = shareIntent.data?.let { returnUri ->
            //     contentResolver.acquireContentProviderClient(returnUri)
            // }
            //client.localContentProvider.openFile()
            uriText = strings.toString()
        } else if (action == Intent.ACTION_SENDTO || action == Intent.ACTION_VIEW) {
            //println("$action: with data ${shareIntent.data} dataString ${shareIntent.dataString}")
            uriText = "[<<${shareIntent.dataString}>>]"
        } else {
            var uri = shareIntent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            //println("got uri $uri")
            uriText =  "[<<$uri>>]"
        }
        sharedData = type + ":" + uriText + ":" + shareIntent.getStringExtra(Intent.EXTRA_TEXT)
        //println("sharedData $sharedData")
    }

    private fun uriToInfo(uri: Uri) {
        /*
     * Get the file's content URI from the incoming Intent,
     * then query the server app to get the file's display name
     * and size.
     */

        contentResolver.query(uri, null, null, null, null)
        ?.use { cursor ->
            /*
             * Get the column indexes of the data in the Cursor,
             * move to the first row in the Cursor, get the data,
             * and display it.
             */
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
            cursor.moveToFirst()
            val name = cursor.getString(nameIndex)
            val size = cursor.getLong(sizeIndex).toString()

        }
    }


}
