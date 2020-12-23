# Codename: Maily
Mail app for iOS, Android and hopefully more platforms in the future. Developed with [Flutter](https://flutter.dev).

## Features
Current development state is very limted to say the least. But it should be enough for interested developers to play around. 
* POP and IMAP service providers are supported, though  POP accounts are not tested at this moment
* Multiple account support
* Unified account - when you have at least 2 accounts, a unified account will show up automatically - with unified inbox, sent, trash, etc
* Mail management: delete, mark as read/unread
* Unsubscribe from newslettters easily
* View attachments - images only at this stage
* Compose messages: compose text messages
* Swipe right to left to delete
* Swipe left to right to mark as read/unread
* Optionally you can block external images when viewing mails
* You can specify aliases and check for + alias support by your mail provider
* Swipe left or right in the message details to view the next/previous message
* Experimental 'stack' display of messages

## Miss a feature or found a bug?

Please file feature requests and bugs at the [issue tracker](https://github.com/Enough-Software/enough_mail_app/issues).


## Contributions
Every contribution is welcome. Since the project is licensed under the [GPL](LICENSE), signing the [Contributor License Agreement](CLA.md) is required.  

This is how you contribute:

* Fork the [enough_mail_app](https://github.com/enough-software/enough_mail_app/) project by pressing the fork button.
* Clone your fork to your computer: `git clone github.com/$your_username/enough_mail_app`
* Do your changes. When you are done, commit changes with `git add -A` and `git commit`.
* Push changes to your personal repository: `git push origin`
* Go to [enough_mail_app](https://github.com/enough-software/enough_mail_app/) and create a pull request.

## License
`enough_mail_app` is licensed under the [GNU Public License 3.0 "GPL"](LICENSE). In a nutshell this means that you can play around as much as possible for private reasons, but that you need to publish your changes under the GPL, as soon as you the code commercially.

## Related Projects
Check out these related projects:
* [enough_mail](https://github.com/Enough-Software/enough_mail) mail libraries in pure Dart.
* [enough_mail_html](https://github.com/Enough-Software/enough_mail_html) generates HTML out of a `MimeMessage`.
* [enough_mail_flutter](https://github.com/Enough-Software/enough_mail_flutter) provides some common Flutter widgets for any mail app.
* [enough_convert](https://github.com/Enough-Software/enough_convert) provides the encodings missing from `dart:convert`.  


![Maily Logo](/maily.png)
