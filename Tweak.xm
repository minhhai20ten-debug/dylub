#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/stat.h>

static void ensureAccountsDirectory(void) {
    @autoreleasepool {
        NSFileManager *fm = [NSFileManager defaultManager];

        // 1. Lấy đường dẫn thư mục Documents chuẩn của app
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count == 0) return;

        NSString *docDir = paths.firstObject;
        NSString *accountsDir = [docDir stringByAppendingPathComponent:@"accounts"];

        // 2. Kiểm tra nếu thư mục accounts chưa tồn tại thì tạo mới
        BOOL isDir = NO;
        if (![fm fileExistsAtPath:accountsDir isDirectory:&isDir] || !isDir) {
            NSError *error = nil;
            NSDictionary *attrs = @{NSFilePosixPermissions: @(0755)};

            BOOL success = [fm createDirectoryAtPath:accountsDir
                         withIntermediateDirectories:YES
                                          attributes:attrs
                                               error:&error];
            if (success) {
                NSLog(@"[WitchAccounts] Da tao thanh cong thu muc: %@", accountsDir);
            } else {
                NSLog(@"[WitchAccounts] Loi khi tao thu muc: %@", error);
            }
        }

        // 3. Phòng hờ Witch sử dụng biến môi trường POJAV_HOME
        const char *pojavHomeEnv = getenv("POJAV_HOME");
        if (pojavHomeEnv != NULL) {
            NSString *pojavHome = [NSString stringWithUTF8String:pojavHomeEnv];
            NSString *pojavAccountsDir = [pojavHome stringByAppendingPathComponent:@"accounts"];
            if (![fm fileExistsAtPath:pojavAccountsDir isDirectory:&isDir] || !isDir) {
                [fm createDirectoryAtPath:pojavAccountsDir
              withIntermediateDirectories:YES
                               attributes:@{NSFilePosixPermissions: @(0755)}
                                    error:nil];
            }
        }
    }
}

// Chạy ngay khi Dyld nạp dylib vào bộ nhớ của Witch
__attribute__((constructor))
static void initWitchAccounts(void) {
    // Tạo ngay lúc nạp
    ensureAccountsDirectory();

    // Đăng ký tạo lại lần nữa khi app đã hoàn tất khởi động
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            ensureAccountsDirectory();
        }];
    });
}