Work Log February 2017  
======================    
**Tobin Harding**      
      
### Format      
start-time stop-time category topic - [ description ]      
      
### Category Key      
misc = miscellaneous      
ops = system operations      
dev = development      
read = read text book      
      
### Topic Key      
misc = miscellaneous      
blog = write blog post    
www = Web programming, usually updating personal website    
kern = Miscellaneous kernel development  
edc = Eudyptula challenge, kernel programming challenge    
mos = Modern Operating Systems - Andrew S. Tanenboum    
os = OS from scratch https://github.com/tcharding/os-tutorial    
  
Wednesday 01/02/17  
------------------  
07:30 08:50 dev kern -  
09:26 10:00 dev kern -  
10:20 11:51 read lkd -  
11:51 12:35 dev kern -   
13:00 15:01 dev kern - memory.c sparse and checkpatch cleanup  
15:23 16:20 dev kern -  
21:15 23:05 dev kern - built stripped down net device driver  
  
Thursday 02/02/17  
-----------------  
07:27 08:03 dev edc - task 07  
08:03 10:40 dev kern - submit memory.c patchset  
10:51 11:37 dev kern - build and run selftests  
11:37 11:59 dev www - kselftest blog post  
12:55 16:10 dev kern - vmalloc_sg_list initial attempt  
  
Wednesday 08/02/17  
------------------  
18:30 21:00 dev kern -  
  
Thursday 09/02/17  
-----------------  
07:21 08:18 ops kern - attempt to reproduce kernel bug  
08:18 10:35 dev edc - start task 08  
10:50 11:41 ops kern - more bug chasing  
11:41 13:21 dev edc - task 08 part 2  
13:21 13:51 read lkd -  
13:51 15:24 dev edc - Complete part 3 and submit task 08  
15:59 18:09 dev kern - net: Checkpath fixes submit patchset  
18:09 19:20 misc kern - looking around  
  
Sunday 12/02/17  
---------------  
09:47 11:00 dev kern -  
11:30 12:48 dev kern - net/core/dev add use of ida  
13:08 13:58 dev kern - submit ida patch  
14:00 14:41 dev edc - resubmit task 08  
14:42 15:41 read mos -  
15:41 18:06 dev kern - purgatory patch submitted  
18:06 18:20 misc ops - mutt  
18:38 20:45 dev kern - sparse warnings  
21:40 00:09 dev kern - various patches  
  
Monday 13/02/17  
---------------  
07:50 08:09 dev kern - submit purgatory patch series  
08:30 08:51 dev kern - misc builds  
08:51 11:44 dev edc - task 09  
11:50 12:35 dev kern -  
12:42 12:54 dev kern -  
14:01 15:40 dev kern -  
15:40 16:42 read mos -  
16:42 17:06 misc kern -  
17:06 18:42 dev kern - vmalloc_sg_list patch to willy  
18:47 19:40 misc kern -  
19:40 20:36 dev os -  
  
Tuesday 14/02/17  
----------------  
07:16 07:32 misc email -  
07:32 12:00 dev os -  
12:00 12:30 read mos -  
12:51 13:00 dev os -  
13:00 13:50 dev kern - purgatory patch v3  
13:50 16:02 misc kern -  
18:26 19:37 dev kern - build tip kernel and bug hunt  
19:37 20:13 dev tos -  
20:13 20:20 dev misc - bash ops coding  
20:20 21:42 dev kern - tos and email reading  
  
Wednesday 15/02/17  
------------------  
07:30 08:24 dev tos -  
08:24 10:16 dev kern -  
10:31 11:49 dev kern - strncpy to strlcpy patches  
11:49 13:05 dev kern -  
13:36 14:29 dev kern - fbtft patchset v2  
14:30 15:18 read mos -  
15:35 16:04 read mos -  
16:04 18:41 dev tos -  
19:24 21:25 dev tos -  
  
Thursday 16/02/17  
-----------------  
07:30 09:30 dev kern - bug hunt  
10:00 12:22 dev kern -  
13:08 15:15 dev kern - strlcpy softmac_wx issue  
15:15 15:31 misc kern -  
15:55 17:37 read mos -  
17:52 19:29 dev tos -  
19:48 21:30 dev kern -  
  
Monday 20/02/17  
---------------  
10:04 10:40 dev kern - send patch, email kernel newbies  
10:40 10:47 dev edc - resubmit task 09  
12:00 12:42 dev kern - ks7010 checkpatch fixes  
12:43 13:02 read mos -  
13:24 14:33 read mos -  
14:33 19:53 dev kern - ks7010 second patch series  
19:56 20:52 read mos -  
  
Tuesday 21/02/17  
----------------  
07:20 08:27 misc kern - read Documentation/process/*  
08:33 11:01 dev kern -  
11:12 12:37 ops misc - procmail to maildrop  
12:37 13:51 read mos -  
14:49 15:32 dev kern -  
19:00 22:18 dev kern - comed patch set v1  
  
Wednesday 22/02/17  
------------------  
07:27 09:03 dev kern -  
09:03 10:55 dev kern -  
11:15 12:55 dev kern -  
12:55 13:36 read mos -  
13:53 14:43 read mos -  
14:43 14:51 dev kern - read mailing lists  
15:11 16:04 dev ldd3 -  
16:04 17:50 dev kern - coccinelle patches  
18:53 21:48 dev tos -  
  
Thursday 23/02/17  
-----------------  
07:27 08:52 dev kern - sort out current active patches  
08:57 09:51 dev kern - bare bones os  
09:51 11:57 dev kern - meaty skeleton tutorial  
11:57 12:03 misc email -  
12:42 17:59 dev tos -  
18:22 20:39 dev tos - get GDT working  
20:39 20:56 dev www -  
20:56 21:23 dev tos -  
  
Monday 27/02/17  
---------------  
08:07 11:56 dev tos -  
12:20 12:26 dev tos -  
12:26 14:16 dev kern - drivers/staging/ks7010/ks7010_sdio.c patch  
14:16 14:49 dev kern -  
14:53 16:14 read mos -  
16:15 17:38 dev kern - comedi patch  
19:47 21:36 dev kern - edc task 11  
  
Tuesday 28/02/17  
----------------  
06:52 07:19 misc kern - emails  
07:19 08:15 dev kern - comedi patch v2  
08:15 10:55 dev kernel - edc  
11:27 12:20 dev ker - edc submit task 11  
12:20 15:30 dev tos - reimplement IRQ and ISRs  
19:28 21:15 dev kern - learn about kprobes/jprobes  
21:15 21:30 misc kern - email  
  
