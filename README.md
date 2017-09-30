# AVPlayerCacheDemo

AVPlayer缓存原理

1、    当播放器需要预先缓存一些数据的时候，不让播放器直接向服务器发起请求，而是向我们自己写的某个类（resourceLoader）发起缓存请求。

2、    resourceLoader根据播放器的缓存请求的请求内容，向服务器发起请求。

3、    服务器返回resourceLoader所需的数据。

4、    resourceLoader把服务器返回的数据写进本地的缓存文件中，同时将数据回填给请求。

5、    当整首歌都缓存完成以后，resourceLoader需要把缓存文件拷贝一份，改个名字，这个文件就是我们所需要的本地持久化文件。

6、    下次播放器再播放歌曲的时候，先判断下本地有木有这个名字的文件，有则播放本地文件，木有则向resourceLoader要数据


CocoaPods导入：

$ pod install AVPlayerCache


使用：

NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:url] resolvingAgainstBaseURL:NO];

self.resourceLoader.scheme = components.scheme;

components.scheme = @"stream";

AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:components.URL options:nil];

[urlAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_queue_create("ResourceLoaderQueue", DISPATCH_QUEUE_SERIAL)];

playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];


缓冲说明

可在resourceLoader中设置cachesFolder，自动将缓冲完成的文件拷贝到沙盒中的Cache下的该目录。

也可在缓冲完成后获取resourceLoader中的tmpfile，为该缓冲文件完整路径，若缓冲未完成或缓冲文件不正确，则该字段为nil。
