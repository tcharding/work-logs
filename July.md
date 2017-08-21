Work Log July 2017
==================  
**Tobin Harding**    
    
### Format    
start-time stop-time category topic - [ description ]    
    
### Category Key    
misc = miscellaneous    
ops = system operations    
dev = development    
read = read text book    
slo = learn online  (read or online course)  
    
### Topic Key    
misc = miscellaneous    
blog = write blog post  
www = Web programming, usually updating personal website  
kern = Miscellaneous kernel development
edc = Eudyptula challenge, kernel programming challenge  
pp = Programming Pearls, Jon Bentley  
mmm = The Mythical Man-Month - Frederick P. Brooks Jr  
k8s = Kubernetes  
gopl = The Go Programming Language - Alan A. A. Donovan, Brian W. Kernhigan

Monday 17/07/17
---------------
09:35 13:37 ops misc -
14:54 16:02 read pp -
16:02 17:30 dev misc - document writing, kernel dev howto
19:38 21:30 read mmm -

Tuesday 18/07/17
----------------
20:03 22:52 misc kern - edc challenge and kernel hacking howtos

Wednesday 19/07/17
------------------
08:18 08:40 dev edc - task 18 resubmit
08:40 11:54 dev blog - write kernel dev part 1 blog post
12:30 12:56 dev blog - finialize blog post and deploy
12:56 15:34 dev k8s - exploration of k8s code base
15:35 16:03 dev go - go recap
16:24 17:30 dev go - hackerrank
20:12 20:22 read mmm -
20:22 20:52 read pp -
20:53 21:59 read k8s - read documentation

Thursday 20/07/17
-----------------
08:00 11:53 dev blog - kernel dev part 2
12:47 17:06 slo k8s - kubernetes tutorials, start Udacity online course
17:07 17:13 dev misc - fix worklogs
17:14 17:30 dev go - recap 
20:06 21:12 slo k8s - finish udacity course

Monday 24/07/17
---------------
14:10 14:40 dev go -
14:40 17:26 dev k8s - start to explore pkg/kubelet/kuberuntime
20:14 21:30 dev go - Read golang.org

Tuesday 25/07/17
----------------
07:33 08:46 dev blog - finish kernel dev part 2 post
08:46 09:55 read gopl - read ch3
09:55 11:19 dev gopl - exercises from chapter 3
11:56 12:16 read pp -
12:16 13:38 dev k8s - exploration of kubelet
13:38 14:17 dev go - tour of go
14:17 17:07 read go - effective go website
20:32 21:59 dev k8s - remove duplicate code in kubelet_test.go

Wednesday 26/07/17
------------------
07:38 09:11 dev k8s - explore kubelet
09:11 11:50 dev k8s - kubelet_test refactoring, PR submitted
12:15 12:44 read pp -
13:06 14:02 misc job - cover letter and application CoreOS
14:02 15:01 read gopl -
15:01 17:01 dev misc - k8s GCE play
20:24 21:31 dev misc - dev environment tweaking

Thursday 27/07/17
-----------------
07:40 08:05 dev k8s - add commit to first PR
08:05 09:36 dev k8s - code base exploration
10:06 11:09 read gopl -
11:09 12:19 dev k8s - kubelet doc.go
12:44 14:59 dev k8s - kubelet doc.go
15:00 16:19 dev k8s - doc.go PR submitted
16:19 17:31 dev k8s - investigate github issues
20:00 22:11 dev k8s - investigate github issues

Tuesday 01/08/17
----------------
11:00 11:59 dev go - code kata
11:59 13:09 read gopl -
13:09 17:30 dev k8s - learn build tools, write verify script
19:45 21:13 dev k8s - exploration

Wednesday 02/08/17
------------------
07:48 11:09 dev misc - write kernel dev intro talk
11:09 11:45 ops misc - prepare for LUG
12:30 16:00 dev k8s - kubectl code exploration
17:30 20:30 xxx xxx - LUG meet
22:40 23:59 dev k8s - cleanup patches

Thursday 03/08/17
-----------------
00:00 02:19 dev k8s - cleanup patches + sig cli metting
11:27 13:49 dev k8s - explore flaky test
13:49 14:26 dev k8s - work on kubectl help comments

Sunday 06/08/17
---------------
16:06 18:52 dev k8s -
19:23 20:57 dev go - play around with cobra library

Monday 07/08/17
---------------
08:00 09:11 misc misc - various github tasks and procrastinating
09:11 10:26 dev k8s -
10:26 10:57 read gopl -
11:19 14:26 dev k8s - two PR cleaning up run.go
14:26 15:18 misc misc - rearrange office
15:26 17:29 dev k8s - clean up cli docs
19:30 21:15 dev k8s - kubectl explain PR

Tuesday 08/08/17
----------------
07:26 09:38 dev k8s - more kubectl cleanup
11:52 15:30 dev k8s - investigate 'edit' bug
15:46 16:20 read gopl -
16:47 19:31 dev cleanup - kubectl help
20:07 21:38 dev go - started talk application

Wednesday 09/08/17
------------------
07:33 09:30 dev k8s - sanitize command examples
09:50 11:55 dev k8s - PR fixing Example verification
12:34 12:44 read gopl -
12:44 14:09 ops misc - docker
14:32 14:56 ops misc - docker
14:56 17:29 dev k8s - node_controller refactor
20:12 21:15 dev k8s - finished initial version node_controller

Thursday 10/08/17
-----------------
07:36 09:38 dev k8s - rework node_controller patches
11:48 12:47 dev finish - and submit node_controller PR
12:47 13:09 dev k8s - check up on all PR's
13:33 16:55 dev k8s - implemented pod integration test
17:15 17:30 dev k8s - testing

Tuesday 15/08/17
----------------
08:01 08:30 misc misc - media research
08:30 09:08 dev k8s -
15:08 17:27 dev kern - conference talk
19:37 20:32 dev k8s -

Wednesday 16/08/17
------------------
09:55 12:44 dev misc - kernel hakcing tutorial
13:30 15:14 dev k8s - explore issues
15:14 17:25 dev go - start constant project
20:02 22:47 dev go - finish constant extraction project
22:47 23:20 misc misc - email requesting mentorship
23:20 23:59 dev k8s - rebase and fix PR

Thursday 17/08/17
-----------------
00:00 00:15 dev k8s - rebase and fix PR
00:15 01:24 dev k8s -
01:44 02:50 misc k8s - sig/cli meeting
11:54 12:27 dev k8s - tidy up PRs

Monday 21/08/17
---------------
11:20 14:02 dev k8s - covnersion PR
14:02 14:33 misc job - Heptio job application

