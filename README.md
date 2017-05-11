# NCMessaging
Tool for quick display Alert, Action Sheet and Toast for iOS, and handle action by Block

## Easy way to use like


###Alert
```
NCMessaging.alert(message: String?, callback: ((Int) -> Void)?, buttons: String...)
```
```
NCMessaging.alert(title:String, message: String?, callback: ((Int) -> Void)?, buttons: String...)
```

###Action Sheet
```
NCMessaging.actionSheet(callback:((Int) -> Void)?, cancel:String?, buttons:String...)
```
```
NCMessaging.actionSheet(title:String?, callback:NCMessagingCallback?, cancel:String?, buttons:String...)
```
###Toast
```
NCMessaging.toast(message:String, callback:((Int) -> Void)?)
```
>for Action Sheet `callback`, `cancel` string will call with index = 0 if not nil
