#Linux　Chapter. Screen Programming(II)

## curses 函数


`refresh()` 将缓存中的内容刷新到显示器上
 `clear()`　清除屏幕内容（代价大）
 使用`move (x, y)  addstr(" ") ` 来替代，清空指定小块内容

 +  例子 
 ***
	for (int i = 0; i < lines; i ++) {
		clear();
		move(i, i + 1);
		addstr("Hello World!");
		if (i & 1)	standend();
		else 		standout();
		refresh();
		sleep(1);
		move (i, i + 1);
		addstr ("           ");
	}

##控制
#### sleep  (库函数)
` #include <unistd.h>` 头文件
`sleep()` 秒为单位
`usleep()` 10^-6^秒为单位

####pause
` #include <unistd.h>` 头文件
挂起一个进程，直到一个信号发生
捕获到信号时，return -1

+ 例子
***
	#include <stdio.h>
	#include <signal.h>
	#include <unistd.h>
	// sleep(5) == 本质的系统调用
	void wakeup (int a) { printf("I am wake up \n"); } 
	int main () {
		signal(SIGALRM, wakeup)
		alarm(5);
		pause(); // 挂起一个进程，直到一个信号发生
		return 0;
	}

####interval timer

`SIGALRM` 在定时器终止时发送给进程的信号
设置初始时间，间歇性产生的时间

+ Linux 系统为每个进程维护 3 种计时器
`  Real`
物理时间，程序执行的实际时间
`Virtual `
运行在用户态时消耗的时间，实际时间减去系统调用和程序睡眠的时间，如同篮球赛的时间，不计中断
` Prof` 
系统调用，用户代码和内核代码的运行时间

>计时器会定时向进程发送时钟信号
三个计时器发送的时钟信号分别为`SIGALRM`，`SIGVTALRM`，`SIGPROF`

+ 相关属性
`it_value`　初始时间　　双精度，秒和微秒
`it_interval`　间隔时间

+ 　`man -k itimer`
`int getitimer(int which,struct itimerval *value);`
`int setitimer(int which,const struct itimerval *value,struct itimer val*ovalue);`
+ 例子
***
	#include <stdio.h>
	#include <signal.h>
	#include <sys/time.h>
	// int setitimer()
	// oldvalue　用于之后的回复
	void wakeup (int num) {
		printf("I am wake up\n");
	} 
	int main () {
		signal(SIGALRM, wakeup); /// 修改pause
		struct itimerval itv;
		itv.it_interval.tv_sec = 1;
		itv.it_interval.tv_usec = 500000;
		itv.it_value.tv_sec = 5;
		itv.it_value.tv_usec = 0;
		// 5s 中开始执行，每１.5ｓ循环
		setitimer(ITIMER_REAL, &itv, NULL);
		while (1) {
			printf("sleep");
			flush();
			pause();
		}
	}
	
####软中断
设置定时器并且设定信号进行中断为软中断，类似多线程处理
多线程，在线程间切换，效率相对低。




#Linux    Chapter.  Processes　
####属性
+ `ps` 查看系统进程
　`TTY`进程状态（使用哪个终端）
`ps -l` 查看进程详细信息
`S` status 　进程状态包括　`S` sleep  `R` running 　`Z` zombie
`UID` 拥有进程的用户id
`PPID` parent 进程ID
`PRI` 优先级， 值越小，优先级越高
`NI` nice值，进程优先级的修正数值，可以为负值
+ 相关操作
sort & 对PRI进行排序，& 在后台执行
`nice -n 5 sort &` 　
`renice 6 45354 ` // 将PID为45354的进程 修改NI，来修改优先级数
用户只能将NI变大，root 修改的范围是　-19～20
`ps -e`     查看后台进程
`ps aux` 查看其他用户的进程
`top`  类似任务管理器


####生命周期
+ 进程状态：运行，等待（等待CPU分配资源），睡眠（被挂起，等待触发事件）
+ 所有进程是由父进程创建，所有进程的根父进程，`init`，PID为１，整个系统的第一个进程，由操作系统创建
+ 进程执行过程中，杀死父进程之后，子进程的PPID变为1，即`init`。
+  zombie僵尸进程，进程`exit`时有`wait  value`，如果父进程不调用`wait()`进行回收的话，会变成僵尸进程，将占用少量内存

####相关操作
+ `execlp()`
`int execlp(const char *file, const char *arg, ...);`
将当前进程替换为一个新进程，原进程后续将不再执行，且新进程与原进程拥有相同的 PID。（换脑，覆盖原进程内存）
arg 参数为向程序输入的参数，arg 与命令有可能不一样，比如通过`sybolic link`
例子	`execlp("ls", "ls", "-R", "/", NULL);`
	
+ `getpid()`获得当前进程的进程ID

+ `fork()`
头文件 `#include<unistd.h>`
创建新进程，复制当前进程的所有信息，包括执行状态与PC，所以新进程和父进程一样从当前PC之后的命令继续执行。
返回创建子进程的PID，如出错，返回-1，子进程未调用，值为０。
本质，内存中复制父进程的一份页表，指向的代码段不变，指向数据，堆栈等的内容在修改时才进行部分复制。
shell下，我们输入命令的本质即为`fork()`，程序的父进程为shell

***
	#include <stdio.h>
	#include <unistd.h>

	int main(){
		int rv, rv_wait;
		printf("About to execute ls /:\n");
		rv = fork();
		if (0==rv) {
			execlp("ls", "ls", "/",  NULL);
		} else {
			rv_wait = wait(NULL);
			printf("%d is back. Done\n",  rv_wait);
		}
		return 0;
	}

+ `wait()`
头文件　`#include<sys/types.h>`  `#include<sys/wait.h>`
`pid_t wait(int *status);`
可以使父进程等待子进程，也可以等待同组进程。返回进程ID，若出错返回-1。
在一个进程调用了 `exit()` 后，该进程变为僵尸进程状态，通过`wait`进行回收。
调用`wait`时，将阻塞自身进程，直到检测到某个子进程已经退出，回收其信息。

+ `exit()`/ `return `
头文件　`#include<stdlib.h>`
`void exit(int status)`
将终止当前进程，清除PCB。
返回0~255之间的数，作为状态，返回０表示正常退出。
状态为16bit,　高８bit为exit value ，低7bit为signum，中间bit为core dump
16 bit |-----high 8 bit------|  |-| |----low 7 bit-----|
16 bit *`  ` ` ` `  ` ` ` `  ` ` ` `  ` ` ` `  ` ` ` `  ` ` ` `  ` ` ` `  ` ` `*
+ `wait(&status)`
如果调用者有多个子进程，一个终止时，`wait`即返回
终止进程的终止状态将存放在`status`指向的单元。
如果`status`为`NULL`，表示父进程不关心子进程的终止状态。

+ `signal(SIGCHLD, SIG_IGN); `
通知内核对子进程的结束不关心，由内核回收，并且避免父进程被挂起。

+ 例子 (执行时杀死子进程，wait也将返回，观察到状态的变化)
*** 
	#include <stdio.h>
	#include <unistd.h>

	int main() {
		int rv, rv_wait;
		printf("About to cook:\n");
		rv = fork();
		if(0 == rv) {
			for(int i = 0; i < 50; i++) {	
				printf("Go shopping\n");
				sleep(1);
			}
			return 10;
		} else {
			int status;
			rv_wait = wait(& status);
			printf("%d is back. status: %0x\n", rv_wait, status);
		}
		return 0;
	}


***

#性能，性能，性能

#Chapter I/O Redirection & Pipes 重定向和管道
who>wholist.txt

+  UNIX 为每一个进程设计一个标准的I/O
０　标准输入
１　标准输出
２　标准错误输出
默认链接到终端，可以人为接到其他其他输出上，比如文件，以及其他方法
例，　ls more 　ls 吧out传给 more

+ lowest-available-fd　最低可用文件描述符
对应着单个进程的文件打开表，　相当于记录进程是否释放
***
	vi stdiotest.c
	write(1, "arr", length)
	
	./a.out >haha 把标准输出打进去，这样标准错误输出还是直接在shell中输出
	./a.out 2 > haha 把标准错误输出重定向
	perror　
	重定向标准输入
	例子　^D = EOF
	sort < file
***
+ I/O redirection
　- method 1: close() open()
　通过fork　程序从shell　获得 012
　`#include <fcntl.h>` `touch`
　`open("file_name",  0_WRONLY)`
　　`open("file_name",  0_WRONLY|0_CREAT, 0644)`

	-method 2   open close dup (3) // 复制，对链接建立副本，将close的端口连到３　 close(3)
	***
+ Pipes
pipe 管默认插在进程的３和４上
fork　管道也是同一个管道
close 1 　dup 4  close 4
子进程 close 0 dup 3 close 3
***
	int pipe(int fd[2])
	shell 里　用 |

# Chapter. Socket
+ 	

	
<by 印飞>
######
