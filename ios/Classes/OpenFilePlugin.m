#import "OpenFilePlugin.h"

@interface OpenFilePlugin ()<UIDocumentInteractionControllerDelegate>
@end

static NSString *const CHANNEL_NAME = @"open_file";

@implementation OpenFilePlugin{
    FlutterResult _result;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    OpenFilePlugin* instance = [[OpenFilePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"open_file" isEqualToString:call.method]) {
        _result = result;
        NSString *msg = call.arguments[@"file_path"];
        if (msg == nil){
            NSDictionary * dict = @{@"message":@"the file path cannot be null", @"type":@-4};
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            result(json);
            return;
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExist = [fileManager fileExistsAtPath:msg];
        if (fileExist) {
            UIDocumentInteractionController* documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:msg]];
            documentController.delegate = self;
            NSString *uti = call.arguments[@"uti"];
            BOOL isBlank = [self isBlankString:uti];
            if (!isBlank) {
                documentController.UTI = uti;
            }
            
            @try {
                BOOL previewSucceeded = [documentController presentPreviewAnimated:YES];
                if (!previewSucceeded) {
                    [documentController presentOpenInMenuFromRect:CGRectMake(500, 20, 100, 100) inView:[self topMostController].view animated:YES];
                }
            } @catch (NSException *exception) {
                NSDictionary * dict = @{@"message":@"File opened incorrectly。", @"type":@-4};
                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                result(json);
            }
        } else {
            NSDictionary * dict = @{@"message":@"the file does not exist", @"type":@-2};
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            result(json);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    NSDictionary * dict = @{@"message":@"done", @"type":@0};
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    _result(json);
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    NSDictionary * dict = @{@"message":@"done", @"type":@0};
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    _result(json);
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return [self topMostController];
}

- (UIViewController*) topMostController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}
@end
