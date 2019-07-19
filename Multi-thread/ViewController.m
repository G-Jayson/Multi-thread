//
//  ViewController.m
//  Multi-thread
//
//  Created by G-Jayson on 2019/7/16.
//  Copyright © 2019 G-Jayson. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, retain) dispatch_semaphore_t semaphoret;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%s : %@", __func__, [NSThread currentThread]);
    
    /**************************  创建线程  *************************/
    
    // pthread
    
    pthread_t thread = NULL;
    NSString *paramStr = @"paramStr";

    // 可接收返回值判断线程有没有创建成功  0 成功 !0 失败
    int res = pthread_create(&thread,               // 线程对象，传递地址
                   NULL,                            // 线程属性，可设置为null
                   pthreadMethod,                   // 指向函数的指针
                   (__bridge void *)(paramStr));    // 函数需要接受的参数，可为null

    if (res == 0) {
        NSLog(@"线程创建成功！pthread begin");
    }

    // 设置子线程的状态为 detached, 则该线程运行结束后会自动释放所有资源，或者在子线程中添加 pthread_detach(pthread_self()),其中 pthread_self() 是获得线程自身的 id
    pthread_detach(thread);
    
    /* 其他方法及参数
    
        pthread_t:                           线程ID
        pthread_attr_t：                     线程属性
        pthread_create()：                   创建一个线程
        pthread_exit()：                     终止当前线程
        pthread_cancel()：                   中断另外一个线程的运行
        pthread_join()：                     阻塞当前的线程，直到另外一个线程运行结束
        pthread_attr_init()：                初始化线程的属性
        pthread_attr_setdetachstate()：      设置脱离状态的属性（决定这个线程在终止时是否可以被结合）
        pthread_attr_getdetachstate()：      获取脱离状态的属性
        pthread_attr_destroy()：             删除线程的属性
        pthread_kill()：                     向线程发送一个信号
        pthread_equal():                     对两个线程的线程标识号进行比较
        pthread_detach():                    分离线程
        pthread_self():                      查询线程自身线程标识号
    
     */
    
    NSLog(@"pthread end");
    
    
    
    
    // NSThread
    
    // 获取当前线程
    NSLog(@"%s : %@", __func__, [NSThread currentThread]);

    // 创建线程 (初始化) 需要调用 start 方法
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(nsThreadMethod:) object:@"thread"];

    NSThread *thread2 = [[NSThread alloc] init];

    NSThread *thread3 = [[NSThread alloc] initWithBlock:^{
        NSLog(@"block 创建 thread  %s : %@", __func__, [NSThread currentThread]);
    }];

    // 设置名称
    thread1.name = @"thread1";

    // 设置线程优先级 调度优先级的取值范围是0.0 ~ 1.0，默认0.5，值越大，优先级越高。
    thread3.threadPriority = 0.0;

    // 启动线程
    [thread1 start];
    [thread3 start];

    // 线程是否正在执行
    if ([thread3 isExecuting]) {
        NSLog(@"thread1 is executing! ");
    }


    // 取消线程
    [thread1 cancel];

    // 线程是否撤销
    if ([thread1 isCancelled]) {
        NSLog(@"thread1 canceled!");
    }


    // 线程是否执行结束
    if ([thread3 isFinished]) {
        NSLog(@"thread3 is finished!");
    }


    // 类方法创建 NSThread  不需要再调用 start 方法
    // block 方式
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"类方法 block 创建 thread : %s : %@", __func__, [NSThread currentThread]);
        
        // 模拟网络请求耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"网络请求中  %@",[NSThread currentThread]);
        }
        
        NSLog(@"网络请求成功 准备回到主线程刷新 UI  %@",[NSThread currentThread]);
        
        // 主线程刷新UI
        [self performSelectorOnMainThread:@selector(mainThreadRefreshUI) withObject:nil waitUntilDone:YES];
    }];

    // SEL 方式
    [NSThread detachNewThreadSelector:@selector(nsThreadMethod:) toTarget:self withObject:nil];

    /*

     [NSThread currentThread];  获取当前线程
     [NSThread isMultiThreaded];  当前代码运行线程是否为子线程

     */

    // 当前线程睡到指定时间
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];

    // 线程沉睡时间间隔 常用在设置启动页间隔
    [NSThread sleepForTimeInterval:1.0];

    // 获取线程优先级 / 设置优先级
    double priority = [NSThread threadPriority];
    NSLog(@"当前线程优先级 : %f", priority);
    [NSThread setThreadPriority:0.9];


    // 返回调用堆栈信息 可用于调试

    // [NSThread callStackSymbols]  return NSArray
    // [NSThread callStackReturnAddresses]   return NSArray
    NSLog(@"callStackSymbols : %@", [NSThread callStackSymbols]);
    NSLog(@"callStackReturnAddresses : %@", [NSThread callStackReturnAddresses]);


    // 线程间通讯  NSObject (NSThreadPerformAdditions) 分类中的方法，所有继承自 NSObject 实例化对象都可调用以下方法

    // 指定方法在主线程中执行
    [self performSelectorOnMainThread:@selector(performMethod:)  // 要执行的方法
                           withObject:nil                         // 执行方法时，要传入的参数 类型为 id
                        waitUntilDone:YES];                       // 当前线程是否要被阻塞，直到主线程将我们指定的代码块执行完，当前线程为主线程，设置为YES时，会立即执行，为NO时加入到RunLoop中在下一次运行循环时执行

    [self performSelectorOnMainThread:@selector(performMethod:)
                           withObject:nil
                        waitUntilDone:YES
                                modes:@[@"kCFRunLoopDefaultMode"]];



    // 指定方法在某个线程中执行
    /*
    - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
    - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
    */
    [self performSelector:@selector(performSelector:)];

    //  指定方法在开启的子线程中执行
    [self performSelectorInBackground:@selector(performMethod:) withObject:nil];
    
    
    
    
    // NSOperation
    // 由于NSOperation是一种抽象类，所以在使用过程中，我们需要用NSOperation的子类 NSInvocationOperation、NSBlockOperation
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationMethod:) object:nil];

    // 启动任务 不添加到队列，直接 start 则在主线程执行
//    [operation1 start];



    // NSBlockOperation
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程执行
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"这是NSBlockOperation执行的任务 %@",[NSThread currentThread]);
        }
    }];
    
    // 只要NSBlockOperation封装的操作数 >1，就会异步执行操作
    // 添加额外的任务 （在子线程中执行）
    [blockOperation1 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"这是让NSBlockOperation另外执行的任务1 %@",[NSThread currentThread]);
        }
    }];

    [blockOperation1 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"这是让NSBlockOperation另外执行的任务2 %@",[NSThread currentThread]);
        }
    }];
    
    // 启动任务  两种方法
    // [blockOperation1 start];
    
    // 添加任务到队列中，如果使用类方法 mainQueue ，则在主线程运行，否则在子线程中执行
    // NSOperation 可以调用 start 方法来执行任务，但默认是同步执行的
    // 如果将 NSOperation 添加到 NSOperationQueue（操作队列）中，系统会自动异步执行 NSOperation 中的操作
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    // 设置最大并发数， 可以同时执行的任务数
    operationQueue.maxConcurrentOperationCount = 3;
    // 添加任务到队列
    [operationQueue addOperation:operation1];

    // 可通过类方法直接添加
    // [[NSOperationQueue mainQueue] addOperation:operation1];

    [operationQueue addOperation:blockOperation1];


    // 暂停队列
    [operationQueue setSuspended:YES];  // YES 暂停  NO 恢复
    
    // 恢复队列，继续执行
    // operationQueue.suspended = NO;
    
    // 暂停（挂起）队列，暂停执行
    // operationQueue.suspended = YES;
    
    NSLog(@"%d", [operationQueue isSuspended]);

    [NSThread sleepForTimeInterval:3];

    operationQueue.suspended = NO;

    // 取消队列
    [operationQueue cancelAllOperations];
    
    
    // 操作依赖
    // NSOperation之间可以设置依赖来保证执行顺序，但是不能相互依赖
    // 比如 A 执行完 执行 C，最后才能执行 B
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSBlockOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"A 执行完毕  %@", [NSThread currentThread]);
    }];


    NSBlockOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"B 执行完毕  %@", [NSThread currentThread]);
    }];

    NSBlockOperation *operationC = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"C 执行完毕  %@", [NSThread currentThread]);
    }];
    
    // 设置依赖
    [operationC addDependency:operationA];
    [operationB addDependency:operationC];

    [queue addOperation:operationA];
    [queue addOperation:operationB];
    [queue addOperation:operationC];
    
    // 线程间通信
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        // 模拟耗时网路操作
        NSLog(@"开始网络请求");
        [NSThread sleepForTimeInterval:5.0];
        NSLog(@"网络请求结束");

        // 回到主线程刷新
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"主线程刷新 UI");
        }];
    }];
    
    
    
    
    // GCD  (Grand Central Dispatch)
    
    
    // 队列
    // 串行队列（Serial Dispatch Queue）： 每次只有一个任务被执，让任务一个接着一个地执行 （只开启一个线程，一个任务执行完毕后，再执行下一个任务）
    dispatch_queue_t serialQueue = dispatch_queue_create("com.jayson.testQuqeue",  // 队列的唯一标示，用于 DEBUG，可为空
                                                         DISPATCH_QUEUE_SERIAL);   // DISPATCH_QUEUE_SERIAL 表示串行队列，DISPATCH_QUEUE_CONCURRENT 表示并发队列

    // 并发队列（Concurrent Dispatch Queue）： 可以让多个任务并发（同时）执行 （可以开启多个线程，并且同时执行任务）
    dispatch_queue_t conCurrentQueue = dispatch_queue_create("com.jayson.testQuqeue", DISPATCH_QUEUE_CONCURRENT);

    // 主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();

    // 获取全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 同步执行 + 串行队列  (任务都在主线程中执行， 任务按顺序执行，耗时操作会阻塞线程)
    

    NSLog(@"sync + serial begin !");

    dispatch_sync(serialQueue, ^{
        // 任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"当前任务 1 -> %@",[NSThread currentThread]);
        }
    });

    dispatch_sync(serialQueue, ^{
        // 任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"当前任务 2 -> %@",[NSThread currentThread]);
        }
    });

    dispatch_sync(serialQueue, ^{
        // 任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"当前任务 3 -> %@",[NSThread currentThread]);
        }
    });

    NSLog(@"sync + serial end !");
    
    
    // 同步执行 + 并发队列 (任务都在主线程中执行， 任务按顺序执行)
    
//    NSLog(@"sync + conCurrent begin !");
//
//    dispatch_sync(conCurrentQueue, ^{
//        // 任务1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 1 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_sync(conCurrentQueue, ^{
//        // 任务2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 2 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_sync(conCurrentQueue, ^{
//        // 任务3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 3 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    NSLog(@"sync + conCurrent end !");
    
    
//    // 同步执行 + 主队列 (crash  死锁  主线程被阻塞，block不能执行)
//
//    NSLog(@"sync + main  begin !");
//
//    dispatch_sync(mainQueue, ^{
//        // 任务1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 1 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_sync(mainQueue, ^{
//        // 任务2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 2 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_sync(mainQueue, ^{
//        // 任务3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 3 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    NSLog(@"sync + main  end !");
    
    
    // 异步执行 + 串行队列 (任务都在子线程执行，由于是串行队列，每次只能执行一个任务，所以任务一个接一个顺序执行)
    
//    NSLog(@"async + serial begin !");
//
//    dispatch_async(serialQueue, ^{
//        // 任务1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 1 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(serialQueue, ^{
//        // 任务2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 2 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(serialQueue, ^{
//        // 任务3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 3 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    NSLog(@"async + serial end !");
    
    
    // 异步执行 + 并发队列 (任务都在子线程执行，并发队列，同时执行多个任务)
    
//    NSLog(@"async + conCurrent begin !");
//
//    dispatch_async(conCurrentQueue, ^{
//        // 任务1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 1 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(conCurrentQueue, ^{
//        // 任务2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 2 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(conCurrentQueue, ^{
//        // 任务3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 3 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    NSLog(@"async + conCurrent end !");
    
    
    
    // 异步执行 + 主队列 (任务都在主线程执行， 但是异步执行不会做任何等待，所以 begin 和 end 先执行，由于主队列是串行队列，每次只能执行一个任务，所以任务一个接一个顺序执行)
    
//    NSLog(@"async + main  begin !");
//
//    dispatch_async(mainQueue, ^{
//        // 任务1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 1 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(mainQueue, ^{
//        // 任务2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 2 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(mainQueue, ^{
//        // 任务3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
//            NSLog(@"当前任务 3 -> %@",[NSThread currentThread]);
//        }
//    });
//
//    NSLog(@"async + main  end !");
    
    
    // 线程间通信 （ 模拟网络请求完回到主线程刷新UI ）
    
    
//
//    dispatch_async(globalQueue, ^{
//        // 模拟网络请求
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"网络请求 ： %@", [NSThread currentThread]);      // 打印当前线程
//        }
//
//        // 主线程刷新
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"主线程刷新了");
//        });
//    });
    
    
    // 栅栏方法  dispatch_barrier_async
    // dispatch_barrier_async 函数会等待之前追加到并发队列中的任务全部执行完毕之后，再将后面需要追加的任务追加到该异步队列中
    
//    dispatch_async(conCurrentQueue, ^{
//        // 任务 1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务1 ： %@", [NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(conCurrentQueue, ^{
//        // 任务 2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务2 ： %@", [NSThread currentThread]);
//        }
//    });
//
//
//    dispatch_barrier_async(conCurrentQueue, ^{
//        // 任务 barrier
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务barrier ： %@", [NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(conCurrentQueue, ^{
//        // 任务 3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务3 ： %@", [NSThread currentThread]);
//        }
//    });
//
//    dispatch_async(conCurrentQueue, ^{
//        // 任务 4
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务4 ： %@", [NSThread currentThread]);
//        }
//    });

    
    // 延迟执行  dispatch_after
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 3秒之后追加异步任务到主队列中并开始执行
//        NSLog(@"延迟执行 %@ ", [NSThread currentThread]);
//    });
    
    
    // 一次性代码  dispatch_once 常用于创建单例
   
    /*
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这里的代码只执行一次
        NSLog(@"dispatch once");
    });
    */
    
//    [self dispatchOnceTest];
//    [self dispatchOnceTest];
//    [self dispatchOnceTest];
    
    
    
    // 快速迭代方法  dispatch_apply
    
    /*
      通常我们会用 for 循环遍历，但是 GCD 给我们提供了快速迭代的函数dispatch_apply。dispatch_apply按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束
      如果是在串行队列中使用 dispatch_apply，那么就和 for 循环一样，按顺序同步执行。可这样就体现不出快速迭代的意义了
      我们可以利用并发队列进行异步执行。比如说遍历 0~9 这10个数字，for 循环的做法是每次取出一个元素，逐个遍历。dispatch_apply 可以 在多个线程中同时（异步）遍历多个数字
      无论是在串行队列，还是并发队列中，dispatch_apply 都会等待全部任务执行完毕，这点就像是同步操作，也像是队列组中的 dispatch_group_wait方法
    */
    
    /*! dispatch_apply函数说明
     *
     *  @brief  dispatch_apply函数是dispatch_sync函数和Dispatch Group的关联API
     *         该函数按指定的次数将指定的Block追加到指定的Dispatch Queue中,并等到全部的处理执行结束
     *
     *  @param 10    指定重复次数  指定10次
     *  @param queue 追加对象的Dispatch Queue
     *  @param index 带有参数的Block, index的作用是为了按执行的顺序区分各个Block
     *
     */
    
//    NSLog(@"dispatch apply begin!");
//
//    dispatch_apply(10, globalQueue, ^(size_t index) {
//        NSLog(@"%zd  : %@", index, [NSThread currentThread]);
//    });
//
//    // 快速遍历数组  但顺序可能不一致
//    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9];
//    dispatch_apply([array count], globalQueue, ^(size_t index) {
//        NSLog(@"%@", array[index]);
//    });
//
//    NSLog(@"dispatch apply end!");
    
    
    // 队列组 dispatch_group
    /*
      使用场景举例：分别异步执行2个耗时任务，然后当2个耗时任务都执行完毕后再回到主线程执行任务
      调用队列组的 dispatch_group_async 先把任务放到队列中，然后将队列放入队列组中，或者使用队列组的 dispatch_group_enter、dispatch_group_leave 组合 来实现
      dispatch_group_async
      调用队列组的 dispatch_group_notify 回到指定线程执行任务
     */
    
//    NSLog(@"dispatch_group  begin!");
    
//    dispatch_group_t group1 = dispatch_group_create();
    
    
//    dispatch_group_async(group1, globalQueue, ^{
//        // 任务 1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务1 ： %@", [NSThread currentThread]);
//        }
//    });
//
//    dispatch_group_async(group1, globalQueue, ^{
//        // 任务 2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:5];              // 模拟耗时操作
//            NSLog(@"任务2 ： %@", [NSThread currentThread]);
//        }
//    });
//
//    dispatch_group_async(group1, globalQueue, ^{
//        // 任务 3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务3 ： %@", [NSThread currentThread]);
//        }
//    });
    
    
    // dispatch_group_enter 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数+1
//    dispatch_group_enter(group1);
//    dispatch_async(globalQueue, ^{
//        // 任务 1
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务1 ： %@", [NSThread currentThread]);
//        }
//
//        // dispatch_group_leave 标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数-1
//        dispatch_group_leave(group1);
//    });
    
//    dispatch_group_enter(group1);
//    dispatch_async(globalQueue, ^{
//        // 任务 2
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:5];              // 模拟耗时操作
//            NSLog(@"任务2 ： %@", [NSThread currentThread]);
//        }
//
//        dispatch_group_leave(group1);
//    });
//
//    dispatch_group_enter(group1);
//    dispatch_async(globalQueue, ^{
//        // 任务 3
//        for (int i = 0; i < 2; ++i) {
//            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
//            NSLog(@"任务3 ： %@", [NSThread currentThread]);
//        }
//
//        dispatch_group_leave(group1);
//    });
//
//
//    // dispatch_group_notify  异步 不会阻塞当前线程
//    // 所有的异步任务都执行完毕，主线程刷新
//    dispatch_group_notify(group1, dispatch_get_main_queue(), ^{
//        NSLog(@"主线程刷新 UI");
//    });
    
    // 当 group 中未执行完毕任务数为0的时候，才会使dispatch_group_wait解除阻塞，以及执行追加到dispatch_group_notify中的任务
    // dispatch_group_wait 会等待异步任务都执行结束，阻塞当前线程，都结束后才会执行后面
//    dispatch_group_wait(group1, DISPATCH_TIME_FOREVER);
//    NSLog(@"主线程刷新 UI");
    
    // dispatch_group_enter、dispatch_group_leave
//    NSLog(@"dispatch_group  end!");
    
    
    
    // 信号量 dispatch_semaphore
    
    /*
      GCD 中的信号量是指 Dispatch Semaphore，是持有计数的信号，类似于过高速路收费站的栏杆，可以通过时，打开栏杆，不可以通过时，关闭栏杆，在 Dispatch Semaphore 中，使用计数来完成这个功能，计数小于 0 时等待，不可通过，计数为 0 或大于 0 时，计数减 1 且不等待，可通过
      Dispatch Semaphore 提供了三个函数：
      dispatch_semaphore_create：创建一个 Semaphore 并初始化信号的总量
      dispatch_semaphore_signal：发送一个信号，让信号总量加 1
      dispatch_semaphore_wait：可以使总信号量减 1，信号总量小于 0 时就会一直等待（阻塞所在线程），否则就可以正常执行。
     
      注意：信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。
     
      Dispatch Semaphore 在实际开发中主要用于：
     
      保持线程同步，将异步执行任务转换为同步执行任务
      保证线程安全，为线程加锁
     
     */

//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//
//    // 线程同步  等待异步方法结果再执行后续操作
//
//    // 模拟异步耗时操作
//    NSLog(@"semaphore begin！");
//
//    __block NSInteger paramNum = 0;
//
//    // 1. semaphore = 0  （初始创建）
//
//    // 2. 异步方法开始执行
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger i = 0; i < 2; i++) {
//            [NSThread sleepForTimeInterval:2.0];
//            NSLog(@"%s : %@", __func__, [NSThread currentThread]);
//            paramNum += 2;
//        }
//
//        // 4. 发送信号  semaphore + 1 = 1
//        dispatch_semaphore_signal(semaphore);
//    });
//
//    // 3. wait semaphore - 1   ->  semaphore == -1  |  semaphore < 0 此时阻塞 等待异步方法执行完
//    // 5. wait semaphore - 1  ->  semaphore == 0  继续执行
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//    // 执行结束
//    NSLog(@"semaphore end!  paramNum : %ld  %@", paramNum, [NSThread currentThread]);
    
    
    // 线程安全 （ 加锁 ）
    // 例 ： 两个线程同时依次利用下标从后往前移除一个可变数组中的元素，使数组置空 注： 若同时移除同一个下标，会crash
    // 定一个数组下标变量和一个可变数组
//    self.array = [NSMutableArray arrayWithCapacity:0];
//
//    for (NSInteger i = 0; i < 20; i++) {
//        [self.array addObject:[NSString stringWithFormat:@"元素 %ld", i]];
//    }
//
//    self.index = self.array.count - 1;
//
//
//    dispatch_queue_t queue1 = dispatch_queue_create("con.jayson.queue1", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue2 = dispatch_queue_create("con.jayson.queue2", DISPATCH_QUEUE_SERIAL);
//    // 1. 非线程安全示例
//
//    __weak typeof(self) weakSelf = self;
//
//    dispatch_async(queue1, ^{
//        [weakSelf unsafeRemoveArrayItemWithIndex];
//    });
//
//    dispatch_async(queue2, ^{
//        [weakSelf unsafeRemoveArrayItemWithIndex];
//    });
    
    
//    // 2. 线程安全示例
//    self.semaphoret = dispatch_semaphore_create(1);
//
//    __weak typeof(self) weakSelf = self;
//
//    dispatch_async(queue1, ^{
//        [weakSelf safeRemoveArrayItemWithIndex];
//    });
//
//    dispatch_async(queue2, ^{
//        [weakSelf safeRemoveArrayItemWithIndex];
//    });
    
    
}



/**
 非线程安全移除
 */
- (void)unsafeRemoveArrayItemWithIndex {
    // 开始循环
    while (1) {
        if (self.index >= 0) {
            NSLog(@"将要移除数组元素 第 %ld 个", self.index);
            [self.array removeObjectAtIndex:self.index];
            NSLog(@"移除数组元素 第 %ld 个", self.index);
            self.index--;
            [NSThread sleepForTimeInterval:0.5];
        } else {
            NSLog(@"所有元素已移除");
            break;
        }
    }
    
    NSLog(@"数组已置空");
}


/**
 非线程安全移除
 */
- (void)safeRemoveArrayItemWithIndex {
    // 开始循环
    while (1) {
        // 开始操作 加锁
        dispatch_semaphore_wait(_semaphoret, DISPATCH_TIME_FOREVER);
        
        if (self.index >= 0) {
            NSLog(@"将要移除数组元素 第 %ld 个", self.index);
            [self.array removeObjectAtIndex:self.index];
            NSLog(@"移除数组元素 第 %ld 个", self.index);
            self.index--;
            [NSThread sleepForTimeInterval:0.5];
        } else {
            NSLog(@"所有元素已移除");
            
            // 解锁
            dispatch_semaphore_signal(_semaphoret);
            break;
        }
        
        // 结束操作 解锁
        dispatch_semaphore_signal(_semaphoret);
    }
    
    NSLog(@"数组已置空");
}


- (void)dispatchOnceTest {
    NSLog(@"调用");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这里的代码只执行一次
        NSLog(@"dispatch once");
    });
}


void *pthreadMethod(void *parma) {
    for (NSInteger i = 0; i < 5; i++) {
        NSLog(@"%ld --> %s : %@   param: %@", i, __func__, [NSThread currentThread], (__bridge NSString *)(parma));
        [NSThread sleepForTimeInterval:1.0];
    }
    
    return NULL;
}


- (void)nsThreadMethod:(NSThread *)thread {
    for (NSInteger i = 0; i <= 2; i++) {
        NSLog(@"%s : %@  ->  value : %ld", __func__, [NSThread currentThread], i);
    }
}


- (void)performMethod:(NSThread *)thread {
    for (NSInteger i = 0; i <= 2; i++) {
        NSLog(@"%s : %@  ->  value : %ld", __func__, [NSThread currentThread], i);
    }
}


- (void)invocationOperationMethod:(NSInvocationOperation *)operation {
    NSLog(@"%s : %@", __func__, [NSThread currentThread]);
}


- (void)mainThreadRefreshUI {
    NSLog(@"回到了主线程并且刷新 UI  %s : %@", __func__, [NSThread currentThread]);
    
    @synchronized (self) {
        
    }
}

@end
