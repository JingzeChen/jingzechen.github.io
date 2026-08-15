# Reading Input: Lecture 12 - Cache Consistency - Frangipani

> This is a generated evidence bundle, not a finished study guide.
> Keep assigned reading ranges and source boundaries when summarizing.

## Video Sessions

- Part 12: Lecture 12 - Cache Consistency - Frangipani (https://www.bilibili.com/video/BV16f4y1z7kn/?p=12)

## Resources

### paper: Frangipani

- URL: http://nil.csail.mit.edu/6.824/2021/papers/thekkath-frangipani.pdf
- Local path: official-materials/papers/thekkath-frangipani.pdf

#### Archived Content


--- PDF page 1 ---
Frangipani: A Scalable Distributed File System
Chandramohan A. Thekkath
Timothy Mann
Edward K. Lee
Systems Research Center
Digital Equipment Corporation
130 Lytton Ave, Palo Alto, CA 94301
Abstract
The ideal distributed ﬁle system wouldprovide all its userswith co-
herent, shared access tothe sameset of ﬁles,yet would be arbitrarily
scalable to provide more storage space and higher performance to
a growing user community. It would be highly available in spite of
component failures. It would require minimal human administra-
tion, and administration would not become more complex as more
components were added.
Frangipani is a new ﬁle system that approximates this ideal, yet
was relatively easy to build because of its two-layer structure. The
lower layer is Petal (described in an earlier paper), a distributed
storage service that provides incrementally scalable, highly avail-
able, automatically managed virtual disks.
In the upper layer,
multiple machines run the same Frangipani ﬁle system code on top
of a shared Petal virtual disk, using a distributed lock service to
ensure coherence.
Frangipaniis meant to run in a cluster of machinesthat are under
a common administration and can communicatesecurely. Thus the
machines trust one another and the shared virtual disk approach is
practical. Of course, a Frangipani ﬁle system can be exported to
untrusted machines using ordinary network ﬁle access protocols.
We have implemented Frangipani on a collection of Alphas
running DIGITAL Unix 4.0. Initial measurements indicate that
Frangipani has excellent single-server performance and scales well
as servers are added.
1
Introduction
File system administration for a large, growing computer installa-
tion built with today’s technologyis a laborious task. To hold more
ﬁles and serve more users, one must add more disks, attached to
more machines. Each of these componentsrequires human admin-
istration. Groups of ﬁles are often manually assigned to particular
disks, then manually moved or replicated when components ﬁll
up, fail, or become performance hot spots. Joining multiple disk
drives into one unit using RAID technology is only a partial so-
lution; administration problems still arise once the system grows
large enough to require multiple RAIDs and multiple server ma-
chines.
Permission to make digital/hard copy of all or part of this work for personal or
classroom use is granted without fee providedthat copies are not made or distributed
for proﬁt or commercial advantage, the copyright notice, the title of the publication
and its date appear, and notice is given that copying is by permission of ACM, Inc.
To copy otherwise, to republish, to post on servers or to redistribute to lists, requires
prior speciﬁc permission and/or a fee.
Frangipaniis a new scalabledistributed ﬁle systemthat manages
a collection of disks on multiple machines as a single shared pool
of storage.
The machines are assumed to be under a common
administration and to be able to communicatesecurely. There have
been many earlier attempts at building distributed ﬁle systems that
scale well in throughput and capacity [1, 11, 19, 20, 21, 22, 26,
31, 33, 34]. One distinguishing feature of Frangipani is that it has
a very simple internal structure—a set of cooperating machines
use a common store and synchronize access to that store with
locks. This simple structure enables us to handle system recovery,
reconﬁguration, and load balancing with very little machinery.
Another key aspect of Frangipani is that it combines aset of features
that makes it easier to use and administer Frangipani than existing
ﬁle systems we know of.
1. All users are given a consistent view of the same set of ﬁles.
2. More servers can easily be added to an existing Frangipani
installation to increase its storage capacity and throughput,
without changing the conﬁguration of existing servers, or
interrupting their operation. The servers can be viewed as
“bricks” that can be stacked incrementally to build as large a
ﬁle system as needed.
3. A system administrator can add new users without concern
for which machines will manage their data or which disks
will store it.
4. A systemadministrator canmake a full and consistentbackup
of the entire ﬁle system without bringing it down. Backups
can optionally be kept online, allowing users quick access to
accidentally deleted ﬁles.
5. The ﬁle system toleratesand recovers from machine,network,
and disk failures without operator intervention.
Frangipani is layered on top of Petal [24], an easy-to-administer
distributed storage system that provides virtual disks to its clients.
Like a physical disk, a Petal virtual disk provides storage that can
be read or written in blocks.
Unlike a physical disk, a virtual
disk provides a sparse 264 byte address space, with physical stor-
age allocated only on demand. Petal optionally replicates data for
high availability. Petal also provides efﬁcient snapshots [7, 10] to
support consistent backup. Frangipani inherits much of its scala-
bility, fault tolerance, and easy administration from the underlying
storage system, but careful design was required to extend these
properties to the ﬁle system level. The next section describes the
structure of Frangipani andits relationship to Petal in greater detail.

--- PDF page 2 ---
User
program
User
program
User
program
Frangipani
file server
Frangipani
file server
Distributed
lock service
Petal
distributed virtual
disk service
Physical disks
Figure 1: Frangipani layering. Several interchangeable Frangi-
pani servers provide access to one set of ﬁles on one Petal virtual
disk.
Figure 1 illustrates the layering in the Frangipani system. Multi-
ple interchangeable Frangipani servers provide access to the same
ﬁles by running on top of a shared Petal virtual disk, coordinat-
ing their actions with locks to ensure coherence. The ﬁle system
layer can be scaled up by adding Frangipani servers. It achieves
fault tolerance by recovering automatically from server failures
and continuing to operate with the servers that survive. It provides
improved load balancing over a centralized network ﬁle server by
splitting up the ﬁle system load and shifting it to the machines that
are using the ﬁles. Petal and the lock service are also distributed
for scalability, fault tolerance, and load balancing.
Frangipani servers trust one another, the Petal servers, and the
lock service. Frangipani is designed to run well in a cluster of
workstations within a single administrative domain, although a
Frangipani ﬁle system may be exported to other domains. Thus,
Frangipani can be viewed as a cluster ﬁle system.
We have implemented Frangipani under DIGITAL Unix 4.0.
Due to Frangipani’s clean layering atop the existing Petal service,
we were able to implement a working system in only a few months.
Frangipani is targeted for environments with program develop-
ment and engineering workloads. Our tests indicate that on such
workloads, Frangipani has excellent performance and scales up to
the limits imposed by the network.
2
System Structure
Figure 2 depicts one typical assignment of functions to machines.
The machines shown at the top run user programs and the Frangi-
pani ﬁle server module; they can be diskless. Those shown at the
bottom run Petal and the distributed lock service.
The components of Frangipani do not have to be assigned to
machines in exactly the way shown in Figure 2. The Petal and
Frangipani servers need not be on separate machines; it would
make sense for every Petal machine to run Frangipani as well,
particularly in an installation where the Petal machines are not
heavily loaded. The distributed lock service is independent of the
rest of the system; we show one lock server asrunning oneach Petal
server machine, but they could just as well run on the Frangipani
hosts or any other available machines.
2.1
Components
As shown in Figure 2, user programs access Frangipani through
the standard operating system call interface. Programs running
on different machines all see the same ﬁles, and their views are
coherent; that is, changesmade to a ﬁle or directory ononemachine
Petal
server
Lock
server
Petal
server
Lock
server
Petal
server
Lock
server
Petal virtual disk
Network
User programs
File system switch
Frangipani
file server module
Petal
device driver
User programs
File system switch
Frangipani
file server module
Petal
device driver
Figure 2: Frangipani structure. In one typical Frangipani con-
ﬁguration, some machines run user programs and the Frangipani
ﬁle server module; others run Petal and the distributed lock ser-
vice. In other conﬁgurations, the same machines may play both
roles.
are immediately visible on all others. Programs get essentially the
same semantic guarantees as on a local Unix ﬁle system: changes
to ﬁle contents are staged through the local kernel buffer pool
and are not guaranteed to reach nonvolatile storage until the next
applicable fsync or sync system call, but metadata1 changes
are logged and can optionally be guaranteed non-volatile by the
time the system call returns. In a small departure from local ﬁle
system semantics, Frangipani maintains a ﬁle’s last-accessed time
only approximately, to avoid doing a metadata write for every data
read.
The Frangipani ﬁle server module on each machine runs within
the operating system kernel. It registers itself with the kernel’s ﬁle
system switch as one of the available ﬁle system implementations.
The ﬁle server module uses the kernel’s buffer pool to cache data
from recentlyusedﬁles. It readsand writes Petal virtual disksusing
the local Petal device driver. All the ﬁle servers read and write the
same ﬁle system data structures on the shared Petal disk, but each
server keeps its own redo log of pending changes in a distinct
section of the Petal disk. The logs are kept in Petal so that when
a Frangipani server crashes, another server can access the log and
run recovery. TheFrangipani servers have no needto communicate
directly with one another; they communicate only with Petal and
the lock service. This keepsserver addition, deletion, and recovery
simple.
The Petal device driver hides the distributed nature of Petal,
making Petal look like an ordinary local disk to higher layers of
the operating system. The driver is responsible for contacting the
1We deﬁne metadata as any on-disk data structure other than the contents of an
ordinary ﬁle.

--- PDF page 3 ---
correct Petal server and failing over to another when necessary.
Any Digital Unix ﬁle system can run on top of Petal, but only
Frangipani providescoherent accessto the sameﬁles from multiple
machines.
The Petal servers run cooperatively to provide Frangipani with
large, scalable, fault-tolerant virtual disks, implemented on top of
the ordinary physical disks connected to each server. Petal can
tolerate one or more disk or server failures, as long as a majority of
the Petal servers remain up and in communication and at least one
copy of each data block remains physically accessible. Additional
details on Petal are available in a separate paper [24].
The lock service is a general-purpose service that provides
multiple-reader/single-writer locks to clients on the network. Its
implementation is distributed for fault tolerance and scalable per-
formance. Frangipani uses the lock service to coordinate access to
the virtual disk and to keep the buffer caches coherent across the
multiple servers.
2.2
Security and the Client/Server Conﬁguration
In the conﬁguration shown in Figure 2, every machine that hosts
user programs also hosts a Frangipani ﬁle server module. This
conﬁgurationhas the potential for goodload balancingand scaling,
but poses security concerns. Any Frangipani machine can read or
write any block of the shared Petal virtual disk, so Frangipani must
run only on machines with trusted operating systems; it would
not be sufﬁcient for a Frangipani machine to authenticate itself to
Petal as acting on behalf of a particular user, as is done in remote
ﬁle access protocols like NFS. Full security also requires Petal
servers and lock servers to run on trusted operating systems, and
all three types of components to authenticate themselves to one
another. Finally, to ensure ﬁle data is kept private, users should be
prevented from eavesdropping on the network interconnecting the
Petal and Frangipani machines.
One could fully solve these problems by placing the machines
in an environment that prevents users from booting modiﬁed op-
erating system kernels on them, and interconnecting them with
a private network that user processes are not granted access to.
This does not necessarily mean that the machines must be locked
in a room with a private physical network; known cryptographic
techniques for secure booting, authentication, and encrypted links
could be used instead [13, 37]. Also, in many applications, partial
solutions may be acceptable; typical existing NFS installations are
not secure against network eavesdropping or even data modiﬁca-
tion by a user who boots a modiﬁed kernel on his workstation. We
have not implemented any of these security measures to date, but
we could reach roughly the NFS level of security by having the
Petal servers accept requests only from a list of network addresses
belonging to trusted Frangipani server machines.
Frangipani ﬁle systems can be exported to untrusted machines
outside an administrative domain using theconﬁguration illustrated
in Figure 3. Here we distinguish between Frangipani client and
server machines. Only the trusted Frangipani servers communicate
with Petal and the lock service. These can be located in a restricted
environment and interconnected by a private network as discussed
above. Remote, untrusted, clients talk to the Frangipani servers
through a separate network and have no direct access to the Petal
servers.
Clients can talk to a Frangipani server using any ﬁle access pro-
tocol supported by the host operating system, such as DCE/DFS,
NFS, or SMB, becauseFrangipani looks just like a local ﬁle system
on the machine running the Frangipani server. Of course, a pro-
User programs
File system switch
NFS or DFS client
File system switch
Frangipani
file server module
NFS or DFS server
Petal
device driver
  Network
  To lock service
  and Petal
Frangipani
client
machine
Frangipani
server
machine
Figure 3: Client/server conﬁguration. A Frangipani server can
provide ﬁle access not only for the local machine, but also for re-
mote client machines that connect via standardnetwork ﬁle system
protocols.
tocol that supports coherent access (such as DCE/DFS) is best, so
that Frangipani’s coherence across multiple servers is not thrown
away at the next level up. Ideally, the protocol should also support
failover from one Frangipani server to another. The protocols just
mentioned do not support failover directly, but the technique of
having a new machine take over the IP address of a failed machine
has been used in other systems [3, 25] and could be applied here.
Apart from security, there is a second reason for using this
client/server conﬁguration. Because Frangipani runs in the kernel,
it is not quickly portable across different operating systems or even
different versions of Unix. Clients can use Frangipani from an
unsupported system by accessing a supported one remotely.
2.3
Discussion
The idea of building a ﬁle system in two layers—a lower level
providing a storage repository and a higher level providing names,
directories, and ﬁles—is not unique to Frangipani. The earliest
example we know of is the Universal File Server [4]. However,
the storage facility provided by Petal is substantially different from
earlier systems, leading to a different higher level structure as well.
Section 10 contains detailed comparisons with previous systems.
Frangipani has been designed to work with the storage abstrac-
tion provided by Petal.
We have not fully considered the de-
sign changesneeded to exploit alternative storage abstractions like
NASD [13].
Petal provides highly available storage that can scale in through-
put andcapacity as resourcesare addedto it. However, Petal has no
provision for coordination or sharing the storage among multiple
clients. Furthermore, most applications cannot directly use Petal’s
client interface because it is disk-like and not ﬁle-like. Frangipani
provides a ﬁle system layer that makes Petal useful to applications
while retaining and extending its good properties.
A strength of Frangipani is that it allows transparent server
addition, deletion, and failure recovery. It is able to do this easily
by combining write-ahead logging and locks with a uniformly
accessible, highly available store.
Another strength of Frangipani is its ability to create consis-
tent backups while the system is running. Frangipani’s backup

--- PDF page 4 ---
0
1
255
...
...
 Param−
eters
Logs
Allocation
bitmaps
Inodes
512 B each
Small blocks
4 KB each
Large blocks
1 TB each
...
...
0
1T
2T
5T
6T
134T 135T 136T 2^64
...
Figure 4: Disk layout. Frangipani takes advantage of Petal’s large, sparse disk address space to simplify its data structures. Each server
has its own log and its own blocks of allocation bitmap space.
mechanism is discussed in Section 8.
There are three aspects of the Frangipani design that can be
problematic. Using Frangipani with a replicated Petal virtual disk
implies that logging sometimes occurs twice,once to the Frangipani
log, andonceagainwithin Petal itself. Second,Frangipanidoesnot
use disk location information in placing data—indeed it cannot—
becausePetal virtualizes the disks. Finally, Frangipani locks entire
ﬁles and directories rather than individual blocks.
We do not
have enough usage experience to evaluate these aspects of our
design in a general setting,but despite them, Frangipani’s measured
performance on the engineering workloads we have tested is good.
3
Disk Layout
Frangipani uses the large, sparse disk address space of Petal to
simplify its data structures. The general idea is reminiscent of
past work on programming computers with large memory address
spaces [8]. There is so much address space available that it can be
parcelled out generously.
A Petal virtual disk has264bytes of addressspace. Petal commits
physical disk space to virtual addressesonly when they are written.
Petal also provides a decommit primitive that frees the physical
space backing a range of virtual disk addresses.
To keep its internal data structures small, Petal commits and
decommits space in fairly large chunks, currently 64 KB. That is,
each 64 KB range of addresses
  216


1

 216
 in which
some data has been written and not decommitted has 64 KB of
physical disk space allocated to it. Thus Petal clients cannot afford
to make their data structures too sparse, or too much physical disk
space will be wasted through fragmentation. Figure 4 shows how
Frangipani divides up its virtual disk space.
The ﬁrst region stores shared conﬁguration parameters and
housekeeping information. We allow one terabyte (TB) of vir-
tual space for this region, but in fact only a few kilobytes of it are
currently used.
The second region stores logs. Each Frangipani server obtains
a portion of this space to hold its private log. We have reserved
one TB (240 bytes) for this region, partitioned into 256 logs. This
choice limits our current implementation to 256 servers, but this
could easily be adjusted.
Thethird region is usedfor allocationbitmaps, to describewhich
blocks in the remaining regions are free. Each Frangipani server
locks a portion of the bitmap space for its exclusive use. When
a server’s bitmap space ﬁlls up, it ﬁnds and locks another unused
portion. The bitmap region is 3 TB long.
The fourth region holds inodes. Each ﬁle needs an inode to
hold its metadata, such as timestamps and pointers to the location
of its data.2 Symbolic links store their data directly in the inode.
We have made inodes 512 bytes long, the size of a disk block,
thereby avoiding the unnecessary contention (“false sharing”) be-
tween servers that would occur if two servers needed to access
different inodes in the same block. We allocate one TB of inode
space, allowing room for 231 inodes. The mapping between bits in
the allocation bitmap and inodes is ﬁxed, so each Frangipani server
allocates inodes to new ﬁles only from the portions of the inode
space that correspondsto its portions of the allocation bitmap. But
any Frangipani server may read, write, or free any existing ﬁle’s
inode.
The ﬁfth region holds small data blocks, each 4 KB (212 bytes)
in size. The ﬁrst 64 KB (16 blocks) of a ﬁle are stored in small
blocks. If a ﬁle grows to more than 64 KB, the rest is stored in one
large block. We allocate 247 bytes for small blocks, thus allowing
up to 235 of them, 16 times the maximum number of inodes.
Theremainder of the Petal addressspaceholdslarge datablocks.
One TB of address space is reserved for every large block.
Our disk layout policy of using 4 KB blocks can suffer from
more fragmentation than a policy that more carefully husbands
disk space.
Also, allocating 512 bytes per inode is somewhat
wasteful of space. We could alleviate these problems by storing
small ﬁles in the inode itself [29]. What we gain with our design
is simplicity, which we believe is a reasonable tradeoff for the cost
of extra physical disk space.
The current scheme limits Frangipani to slightly less than 224
(16 million) large ﬁles, where a large ﬁle is any ﬁle bigger than
64 KB. Also, no ﬁle can be larger than 16 small blocks plus one
large block (64 KB plus 1 TB). If these limits prove too small,
we could easily reduce the size of large blocks, thus making a
larger number available, and permit large ﬁles to span more than
one large block, thus raising the maximum ﬁle size. Should the
264 byte address space limit prove inadequate, a single Frangipani
server can support multiple Frangipani ﬁle systems on multiple
virtual disks.
We have chosenthese ﬁle system parameters basedon our usage
experience with earlier ﬁle systems. We believe our choices will
serve us well, but only time and usage can conﬁrm this.
The
design of Frangipani is ﬂexible enough that we can experiment
with different layouts at the cost of a backup and restore of the ﬁle
system.
4
Logging and Recovery
Frangipani uses write-ahead redo logging of metadata to simplify
failure recovery and improve performance; user data is not logged.
2In this section the word ﬁle includes directories, symbolic links, and the like.

--- PDF page 5 ---
Each Frangipani server has its own private log in Petal. When
a Frangipani ﬁle server needs to make a metadata update, it ﬁrst
creates a record describing the update and appends it to its log in
memory. These log records are periodically written out to Petal
in the same order that the updates they describe were requested.
(Optionally, we allow the log records to be written synchronously.
This offers slightly better failure semantics at the cost of increased
latency for metadata operations.) Only after a log record is written
to Petal does the server modify the actual metadata in its perma-
nent locations. The permanent locations are updated periodically
(roughly every 30 seconds) by the Unix update demon.
Logs are bounded in size—128 KB in the current implementa-
tion. Given Petal’s allocation policy, a log will be composed of
two 64 KB fragments on two distinct physical disks. The space
allocated for each log is managed as a circular buffer. When the
log ﬁlls, Frangipani reclaims the oldest 25% of the log space for
new log entries. Ordinarily, all the entries in the reclaimed area
will refer to metadata blocks that have already been written to
Petal (in a previous sync operation), in which case no additional
Petal writes need to be done. If there are metadata blocks that
have not yet been written, this work is completed before the log is
reclaimed. Given the size of the log and typical sizes of Frangi-
pani log records (80–128 bytes), the log can ﬁll up between two
periodic sync operations if there are about 1000–1600operations
that modify metadata in that interval.
If a Frangipani server crashes, the system eventually detects
the failure and runs recovery on that server’s log. Failure may be
detected either by a client of the failed server, or when the lock
service asks the failed server to return a lock it is holding and gets
no reply. The recovery demon is implicitly given ownership of
the failed server’s log and locks. The demon ﬁnds the log’s start
and end, then examines each record in order, carrying out each de-
scribed update that is not already complete. After log processing
is ﬁnished, the recovery demon releases all its locks and frees the
log. The other Frangipani servers can then proceed unobstructed
by the failed server, and the failed server itself can optionally be
restarted (with an empty log). As long as the underlying Petal vol-
ume remains available, the system tolerates an unlimited number
of Frangipani server failures.
To ensure that recovery can ﬁnd the end of the log (even whenthe
disk controllers write data out of order), we attach a monotonically
increasing log sequence number to each 512-byte block of the log.
The end of the log can be reliably detected by ﬁnding a sequence
number that is lower than the preceding one.
Frangipani ensures that logging and recovery work correctly in
the presence of multiple logs. This requires attention to several
details.
First, Frangipani’s locking protocol, described in the next sec-
tion, ensures that updates requested to the same data by different
servers are serialized. A write lock that covers dirty data can change
owners only after the dirty data has been written to Petal, either
by the original lock holder or by a recovery demon running on its
behalf. This implies that at most one log can hold an uncompleted
update for any given block.
Second, Frangipani ensures that recovery applies only updates
that were logged since the server acquired the locks that cover
them, and for which it still holds the locks. This is needed to
ensure that the serialization imposed by the locking protocol is
not violated.
We make this guarantee by enforcing a stronger
condition: recovery never replaysa log recorddescribing anupdate
that has already been completed. To accomplish the latter, we keep
a version number on every 512-byte metadata block. Metadata
such as directories, which span multiple blocks, have multiple
version numbers. For each block that a log record updates, the
record contains a description of the changes and the new version
number. During recovery, the changes to a block are applied only
if the block version number is less than the record version number.
Because user data updates are not logged, only metadata blocks
have space reserved for version numbers. This creates a compli-
cation. If a block were used for metadata, freed, and then reused
for user data, old log records referring to the block might not be
skipped properly after the version number was overwritten with ar-
bitrary user data. Frangipani avoids this problem by reusing freed
metadata blocks only to hold new metadata.
Finally, Frangipani ensures that at any time only one recovery
demon is trying to replay the log region of a speciﬁc server. The
lock service guarantees this by granting the active recovery demon
an exclusive lock on the log.
Frangipani’s logging and recovery schemes assume that a disk
write failure leaves the contents of a single sector in either the old
state or the new state but never in a combination of both. If a sector
is damaged such that reading it returns a CRC error, Petal’s built-in
replication can ordinarily recover it. If both copies of a sector were
to be lost, or if Frangipani’s data structures were corrupted by a
software bug, a metadata consistency check and repair tool (like
Unix fsck) would be needed. We have not implemented such a tool
to date.
Frangipani’s logging is not intended to provide high-level se-
mantic guarantees to its users. Its purpose is to improve the per-
formance of metadata updates and to speed up failure recovery by
avoiding the need to run programs like fsck each time a server fails.
Only metadata is logged, not user data, so a user has no guarantee
that the ﬁle system state is consistent from his point of view after
a failure. We do not claim these semantics to be ideal, but they
are the same as what standard local Unix ﬁle systems provide. In
both local Unix ﬁle systems and Frangipani, a user can get better
consistency semantics by calling fsync at suitable checkpoints.
Frangipani’s logging is an application of techniques ﬁrst devel-
oped for databases[2] and later used in several other log-based ﬁle
systems [9, 11, 16, 18]. Frangipani is not a log-structured ﬁle sys-
tem [32]; it does not keepall its data in the log, instead maintaining
conventional on-disk data structures, with a small log as an adjunct
to provide improved performance and failure atomicity. Unlike the
other log-based ﬁle systems cited above, but like the log-structured
ﬁle systems Zebra [17] and xFS [1], Frangipani keeps multiple
logs.
5
Synchronization and Cache Coherence
With multiple Frangipaniservers all modifying shared on-disk data
structures, careful synchronization is needed to give each server a
consistent view of the data, and yet allow enough concurrency
to scale performance as load is increased or servers are added.
Frangipani uses multiple-reader/single-writer locks to implement
the necessarysynchronization. When the lock service detects con-
ﬂicting lock requests, the current holder of the lock is asked to
release or downgrade it to remove the conﬂict.
A read lock allows a server to read the associateddata from disk
and cache it. If a server is asked to release its read lock, it must
invalidate its cache entry before complying. A write lock allows a
server to read or write the associated data and cache it. A server’s
cached copy of a disk block can be different from the on-disk
version only if it holds the relevant write lock. Thus if a server

--- PDF page 6 ---
is asked to release its write lock or downgrade it to a read lock, it
must write the dirty data to disk before complying. It can retain its
cache entry if it is downgrading the lock, but must invalidate it if
releasing the lock.
Instead of ﬂushing the dirty data to disk when a write lock is
released or downgraded, we could have chosen to bypass the disk
and forward the dirty data directly to the requester. We did not
do this for reasons of simplicity. First, in our design, Frangipani
servers do not need to communicate with each other. They com-
municate only with Petal and the lock server. Second, our design
ensures that when a server crashes, we need only process the log
used by that server. If dirty buffers were directly forwarded and the
destination server with the dirty buffer crashed, log entries refer-
ring to the dirty buffer could be spread out acrossseveral machines.
This would pose a problem both for recovery and in reclaiming log
space as it ﬁlls up.
We have divided the on-disk structures into logical segments
with locks for each segment. To avoid false sharing, we ensure
that a single disk sector does not hold more than one data structure
that could be shared. Our division of on-disk data structures into
lockable segments is designed to keep the number of locks reason-
ably small, yet avoid lock contention in the common case, so that
the lock service is not a bottleneck in the system.
Each log is a single lockable segment, because logs are private.
The bitmap space is also divided into segments that are locked
exclusively, so that there is no contention when new ﬁles are allo-
cated. A data block or inode that is not currently allocated to a ﬁle
is protected by the lock on the segment of the allocation bitmap
that holds the bit marking it as free. Finally, each ﬁle, directory,
or symbolic link is one segment; that is, one lock protects both the
inode and any ﬁle data it points to. This per-ﬁle lock granularity is
appropriate for engineering workloads where ﬁles rarely undergo
concurrent write-sharing. Other workloads, however, may require
ﬁner granularity locking.
Some operations require atomically updating several on-disk
data structures covered by different locks. We avoid deadlock by
globally ordering these locks and acquiring them in two phases.
First, a server determines what locks it needs. This may involve
acquiring andreleasingsome locks, to look up namesin a directory,
for example.
Second, it sorts the locks by inode address and
acquires each lock in turn. The server then checks whether any
objects it examined in phase one were modiﬁed while their locks
were released. If so, it releases the locks and loops back to repeat
phase one. Otherwise, it performs the operation, dirtying some
blocks in its cache and writing a log record. It retains each lock
until the dirty blocks it covers are written back to disk.
The cache coherence protocol we have just described is similar
to protocols used for client ﬁle caches in Echo [26], the Andrew
File System [19], DCE/DFS [21], and Sprite [30]. The deadlock
avoidance technique is similar to Echo’s. Like Frangipani, the
Oracle data base (Oracle Parallel Server), also writes dirty data to
disk instead of using cache-to-cache transfers between successive
owners of the write lock.
6
The Lock Service
Frangipani requires only a small, generic set of functions from its
lock service, and we do not expect the service to be a performance
bottleneck in normal operation, so many different implementations
could ﬁll its requirements. We have used three different lock ser-
vice implementations in the course of the Frangipani project, and
other existing lock services could provide the necessary function-
ality, perhaps with a thin layer of additional code on top.
The lock service provides multiple-reader/single-writer locks.
Locks are sticky; that is, a client will generally retain a lock until
some other client needs a conﬂicting one. (Recall that the clients
of the lock service are the Frangipani servers.)
The lock service deals with client failure using leases [15, 26].
When a client ﬁrst contacts the lock service, it obtains a lease. All
locks the client acquires are associated with the lease. Each lease
has an expiration time, currently set to 30 secondsafter its creation
or last renewal. A client must renew its lease before the expiration
time, or the service will consider it to have failed.
Network failures can prevent a Frangipani server from renewing
its lease even though it has not crashed. When this happens, the
server discards all its locks and the data in its cache. If anything in
the cache was dirty, Frangipani turns on an internal ﬂag that causes
all subsequent requests from user programs to return an error. The
ﬁle system must be unmounted to clear this error condition. We
have chosen this drastic way of reporting the error to make it
difﬁcult to ignore inadvertently.
Our initial lock service implementation wasa single, centralized
server that kept all its lock state in volatile memory. Such a server
is adequatefor Frangipani, becausethe Frangipaniservers and their
logs hold enough state information to permit recovery even if the
lock service loses all its state in a crash. However, a lock service
failure would cause a large performance glitch.
Our second implementation stored the lock state on a Petal vir-
tual disk, writing each lock state change through to Petal before
returning to the client. If the primary lock server crashed, a backup
server would read the current state from Petal and take over to pro-
vide continued service. With this scheme, failure recovery is more
transparent, but performance for the common case is poorer than
the centralized, in-memory approach. We did not fully implement
automatic recovery from all failure modes for this implementation
before going on to the next one.
Our third and ﬁnal lock service implementation is fully dis-
tributed for fault tolerance and scalable performance. It consists
of a set of mutually cooperating lock servers, and a clerk module
linked into each Frangipani server.
The lock service organizes locks into tables named by ASCII
strings. Individual locks within tables are named by 64-bit inte-
gers. Recall that a single Frangipani ﬁle system uses only one
Petal virtual disk, although multiple Frangipani ﬁle systems can
be mounted on the same machine. Each ﬁle system has a table
associated with it. When a Frangipani ﬁle system is mounted, the
Frangipani server calls into the clerk, which opens the lock table
associated with that ﬁle system. The lock server gives the clerk
a lease identiﬁer on a successful open, which is used in all sub-
sequent communication between them. When the ﬁle system is
unmounted, the clerk closes the lock table.
Clerks andthe lock servers communicatevia asynchronousmes-
sagesrather than RPC to minimize the amount of memory usedand
to achieve good ﬂexibility and performance. The basic message
types that operate on locks are request, grant, revoke, and release.
The requestandreleasemessagetypesare sent from the clerk to the
lock server, whereas the grant and revoke message types are sent
from the lock server to the clerk. Lock upgrade and downgrade
operations are also handled using these four message types.
The lock service uses a fault-tolerant, distributed failure detec-
tion mechanism to detect the crash of lock servers. This is the
same mechanism used by Petal. It is based on the timely exchange
of heartbeat messages between sets of servers. It uses majority

--- PDF page 7 ---
consensus to tolerate network partitions.
Locks consume memory at the server and at each clerk. In our
current implementation, the server allocates a block of 112 bytes
per lock, in addition to 104 bytes per clerk that has an outstanding
or granted lock request. Each client uses up 232 bytes per lock. To
avoid consuming too much memory becauseof sticky locks, clerks
discard locks that have not been used for a long time (1 hour).
A small amount of global state information that does not change
often is consistently replicated across all lock servers using Lam-
port’s Paxos algorithm [23]. The lock service reuses an imple-
mentation of Paxos originally written for Petal. The global state
information consists of a list of lock servers, a list of locks that each
is responsible for serving, and a list of clerks that have opened but
not yet closed each lock table. This information is used to achieve
consensus, to reassign locks across lock servers, to recover lock
state from clerks after a lock server crash, and to facilitate recovery
of Frangipani servers. For efﬁciency, locks are partitioned into
about one hundred distinct lock groups, and are assigned to servers
by group, not individually.
Locks are occasionally reassigned across lock servers to com-
pensate for a crashed lock server or to take advantage of a newly
recovered lock server. A similar reassignment occurs when a lock
server is permanently added to or removed from the system. In
such cases, the locks are always reassigned such that the number
of locks served by each server is balanced, the number of reassign-
ments is minimized, and each lock is served by exactly one lock
server. The reassignment occurs in two phases. In the ﬁrst phase,
lock servers that lose locks discard them from their internal state.
In the second phase, lock servers that gain locks contact the clerks
that have the relevant lock tables open. The servers recover the
state of their new locks from the clerks, and the clerks are informed
of the new servers for their locks.
When a Frangipani server crashes, the locks that it owns cannot
be released until appropriate recovery actions have been performed.
Speciﬁcally, the crashedFrangipani server’s log must be processed
and any pending updates must be written to Petal. When a Frangi-
pani server’s lease expires, the lock service will ask the clerk on
another Frangipani machine to perform recovery and to then re-
lease all locks belonging to the crashed Frangipani server. This
clerk is granted a lock to ensure exclusive access to the log. This
lock is itself covered by a lease so that the lock service will start
another recovery process should this one fail.
In general, the Frangipani system tolerates network partitions,
continuing to operate when possible and otherwise shutting down
cleanly. Speciﬁcally, Petal can continue operation in the face of
network partitions, as long as a majority of the Petal servers remain
up and in communication, but parts of the Petal virtual disk will be
inaccessibleif there is no replica in the majority partition. The lock
service continues operation as long as a majority of lock servers
are up and in communication. If a Frangipani server is partitioned
away from the lock service, it will be unable to renew its lease.
The lock service will declare such a Frangipani server dead and
initiate recovery from its log on Petal. If a Frangipani server is
partitioned away from Petal, it will be unable to read or write the
virtual disk. In either of thesecases, the server will disallow further
user access to the affected ﬁle system until the partition heals and
the ﬁle system is remounted.
Thereis a small hazard whena Frangipaniserver’s leaseexpires.
If the server did not really crash, but wasmerely out of contact with
the lock service due to network problems, it may still try to access
Petal after its lease has expired. A Frangipani server checksthat its
lease is still valid (and will still be valid for
  margin seconds) before
attempting any write to Petal. Petal, however, does no checking
whena write requestarrives. Thus, if there is a sufﬁcienttime delay
between Frangipani’s lease check and the arrival of the subsequent
write request at Petal, we could have a problem: The lease could
have expired and the lock been given to a different server. We use
a large enough error margin
  margin (15 seconds) that under normal
circumstances this problem would never occur, but we cannot rule
it out absolutely.
In the future we would like to eliminate this hazard; one method
that would work is as follows. We add an expiration timestamp
on each write request to Petal. The timestamp is set to the current
lease expiration time at the moment the write request is generated,
minus
  margin. We then have Petal ignore any write request with a
timestamp less than the current time. This method reliably rejects
writes with expired leases, provided that the clocks on Petal and
Frangipani servers are synchronized to within
  margin.
Another method, which does not required synchronized clocks,
is to integrate the lock server with Petal and include the lease
identiﬁer obtained from the lock server with every write request to
Petal. Petal would then reject any write request with an expired
lease identiﬁer.
7
Adding and Removing Servers
As a Frangipani installation grows and changes,the system admin-
istrator will occasionally need to add or remove server machines.
Frangipani is designed to make this task easy.
Adding another Frangipani server to a running system requires
a minimal amount of administrative work. The new server need
only be told which Petal virtual disk to use and where to ﬁnd the
lock service. The new server contacts the lock service to obtain a
lease, determines which portion of the log space to use from the
lease identiﬁer, and goes into operation. The administrator does
not need to touch the other servers; they adapt to the presence of
the new one automatically.
Removing a Frangipani server is even easier. It is adequate to
simply shut the server off. It is preferable for the server to ﬂush
all its dirty data and release its locks before halting, but this is not
strictly needed. If the server halts abruptly, recovery will run on
its log the next time one of its locks is needed, bringing the shared
disk into a consistent state. Again, the administrator does not need
to touch the other servers.
Petal servers can also be added and removed transparently, as
described in the Petal paper [24].
Lock servers are added and
removed in a similar manner.
8
Backup
Petal’s snapshotfeature provides us with a convenientway to make
consistent full dumps of a Frangipani ﬁle system. Petal allows a
client to create an exact copy of a virtual disk at any point in
time. The snapshot copy appears identical to an ordinary virtual
disk, except that it cannot be modiﬁed. The implementation uses
copy-on-write techniques for efﬁciency. The snapshots are crash-
consistent; that is, a snapshot reﬂects a coherent state, one that
the Petal virtual disk could have been left in if all the Frangipani
servers were to crash.
Hence we can backup a Frangipani ﬁle system simply by taking
a Petal snapshot and copying it to tape. The snapshot will include
all the logs, so it can be restored by copying it back to a new
Petal virtual disk and running recovery on each log. Due to the

--- PDF page 8 ---
crash-consistency, restoring from a snapshot reduces to the same
problem as recovering from a system-wide power failure.
We could improve on this scheme with a minor change to Frangi-
pani, creating snapshots that are consistent at the ﬁle system level
and require no recovery. We can accomplish this by having the
backup program force all the Frangipani servers into a barrier,
implemented using an ordinary global lock supplied by the lock
service. The Frangipani servers acquire this lock in shared mode to
do any modiﬁcation operation, while the backup process requests
it in exclusive mode. When a Frangipani server receives a request
to release the barrier lock, it enters the barrier by blocking all new
ﬁle systemcalls that modify data, cleaning all dirty data in its cache
and then releasing the lock. When all the Frangipani servers have
entered the barrier, the backup program is able to acquire the ex-
clusive lock; it then makes a Petal snapshot and releases the lock.
At this point the servers reacquire the lock in shared mode, and
normal operation resumes.
With the latter scheme, the new snapshot can be mounted as a
Frangipani volume with no need for recovery. The new volume
can be accessed on-line to retrieve individual ﬁles, or it can be
dumped to tape in a conventional backup format that does not re-
quire Frangipani for restoration. The new volumemust bemounted
read-only, however, because Petal snapshots are currently read-
only. In the future we may extend Petal to support writable snap-
shots, or we may implement a thin layer on top of Petal to simulate
them.
9
Performance
Frangipani’s layered structure has made it easier to build than a
monolithic system, but one might expect the layering to exact a
cost in performance. In this section we show that Frangipani’s
performance is good in spite of the layering.
As in other ﬁle systems, latency problems in Frangipani can
be solved straightforwardly by adding a non-volatile memory
(NVRAM) buffer in front of the disks. The most effective place
to put NVRAM in our system is directly between the physical
disks and the Petal server software. Ordinary PrestoServe cards
and drivers sufﬁce for this purpose, with no changes to Petal or
Frangipani needed. Failure of the NVRAM on a Petal server is
treated by Petal as equivalent to a server failure.
Severalaspectsof Frangipaniand Petal combineto provide good
scaling of throughput. There is parallelism at both layers of the
system: multiple Frangipani servers, multiple Petal servers, and
multiple disk arms all working in parallel. When many clients are
using the system, this parallelism increases the aggregate through-
put. As compared with a centralized network ﬁle server,Frangipani
should have less difﬁculty dealing with hot spots, because ﬁle sys-
tem processing is split up and shifted to the machines that are
using the ﬁles. Both the Frangipani and Petal logs can commit up-
dates from many different clients in one log write (group commit),
providing improved log throughput under load. Individual clients
doing large writes also beneﬁt from parallelism, due to Petal’s
striping of data across multiple disks and servers.
9.1
Experimental Setup
We are planning to build a large storage testbedwith about 100Petal
nodes attached to several hundred disks and about 50 Frangipani
servers. Petal nodes will be small array controllers attached to
off-the-shelf disks and to the network. Frangipani servers will be
typical workstations. This testbed would allow us to study the
performance of Frangipani in a large conﬁguration. Since this is
not yet ready, we report numbers from a smaller conﬁguration.
For the measurements reported below, we used seven 333 MHz
DEC Alpha 500 5/333 machines as Petal servers. Each machine
stores data on 9 DIGITAL RZ29 disks, which are 3.5 inch fast
SCSI drives storing 4.3 GB each, with 9 ms average seek time
and 6 MB/s sustained transfer rate. Each machine is connected to
a 24 port ATM switch by its own 155 Mbit/s point-to-point link.
PrestoServe cardscontaining 8 MB of NVRAM were usedon these
servers where indicated below. The seven Petal servers can supply
data at an aggregate rate of 100 MB/s. With replicated virtual
disks, Petal servers can sink data at an aggregate rate of 43 MB/s.
9.2
Single Machine Performance
This subsection compares how well Frangipani’s code path com-
pares with another Unix vnode ﬁle system, namely DIGITAL’s
Advanced File System (AdvFS).
We used AdvFS for our comparison rather thanthe more familiar
BSD-derived UFS ﬁle system [27] because AdvFS is signiﬁcantly
faster than UFS. In particular,AdvFS can stripe ﬁlesacrossmultiple
disks, thereby achieving nearly double the throughput of UFS on
our test machines. Also, unlikeUFS, whichsynchronouslyupdates
metadata, AdvFS uses a write-ahead log like Frangipani.
This
signiﬁcantly reduces the latency of operations like ﬁle creation.
Both AdvFS and UFS have similar performance on reading small
ﬁles and directories.
We ran AdvFS and Frangipani ﬁle systems on two identical
machines with storage subsystems having comparable I/O perfor-
mance. Each machine has a 225 MHz DEC Alpha 3000/700 CPU
with 192 MB of RAM, which is managed by the uniﬁed buffer
cache (UBC). Each is connected to the ATM switch by its own
point-to-point link.
The Frangipani ﬁle system does not use local disks, but accesses
a replicated Petal virtual disk via the Petal device driver. When
accessed through the raw device interface using block sizes of
64 KB, the Petal driver can read and write data at about 16 MB/s,
saturating the ATM link to the Petal server. CPU utilization is
about 4%. The read latency of a Petal disk is about 11 ms.
The AdvFS ﬁle system uses a storage subsystem that has per-
formance roughly equivalent to the Petal conﬁguration we use. It
consists of 8 DIGITAL RZ29 disks connectedvia two 10 MB/s fast
SCSI strings to two backplanecontrollers. When accessedthrough
the raw device interface, the controllers and disks can supply data
at about 17 MB/s with 4% CPU utilization. Read latency is about
10 ms. (We could have connected the AdvFS ﬁle system to a Petal
virtual disk to ensure both ﬁle systems were using identical storage
subsystems. Previous experiments [24] have shown that AdvFS
would have been about 4% slower if run on Petal.
To present
AdvFS in the best light, we chose not to do this.)
It is not our intention to compare Petal’s cost/performance with
that of locally attached disks. Clearly, the hardware resources re-
quired to provide the storage subsystemsfor Frangipani andAdvFS
are vastly different. Our goal is to demonstrate that the Frangipani
code path is efﬁcient compared to an existing, well-tuned com-
mercial ﬁle system. The hardware resources we use for Petal are
non-trivial, but these resources are amortized amongst multiple
Frangipani servers.
Tables 1 and 2 compare performance of the two systems on
standard benchmarks. Each table has four columns. In the AdvFS
Raw column, the benchmark was run with AdvFS directly access-
ing the local disks. In the AdvFS NVR column, the benchmark

--- PDF page 9 ---
was rerun with NVRAM interposed in front of the local disks. In
the Frangipani Raw column, the benchmarkwas run with Frangi-
pani accessing Petal via the device interface. In the Frangipani
NVR column, the Frangipani conﬁguration was retested with the
addition of an NVRAM buffer between Petal and the disks. All
numbers are averaged over ten runs of the benchmarks. Standard
deviation is less than 12% of the mean in all cases.
AdvFS
Frangipani
Phase
Description
Raw
NVR
Raw
NVR
1
Create Directories
0.69
0.66
0.52
0.51
2
Copy Files
4.3
4.3
5.8
4.6
3
Directory Status
4.7
4.4
2.6
2.5
4
Scan Files
4.8
4.8
3.0
2.8
5
Compile
27.8
27.7
31.8
27.8
Table 1: Modiﬁed Andrew Benchmark with unmount opera-
tions. We compare the performance of two ﬁle system conﬁgura-
tions: local access (with and without NVRAM) to the DIGITAL
Unix Advanced File System (AdvFS), Frangipani, and Frangipani
with an NVRAM buffer added between Petal and the disks. We
unmount the ﬁle system at the end of each phase. Each table entry
is an average elapsed time in seconds; smaller numbers are better.
Table 1 gives results from the Modiﬁed Andrew Benchmark, a
widely used ﬁle system benchmark. The ﬁrst phase of the bench-
mark creates a tree of directories. The second phase copies a 350
KB collection of C source ﬁles into the tree.
The third phase
traverses the new tree and examines the status of each ﬁle and
directory. The fourth phase reads every ﬁle in the new tree. The
ﬁfth phase compiles and links the ﬁles.
Unfortunately, it is difﬁcult to make comparative measurements
using the Modiﬁed Andrew Benchmark in its standard form. This
is becausethe benchmarkdoesnot accountfor work that is deferred
by the ﬁle system implementation. The work deferred during one
phase of the benchmark can be performed during a later phase and
thus inappropriately charged to that phase, while some work can be
deferred past the end of the benchmark and thus never accounted
for.
Like traditional Unix ﬁle systems, both AdvFS and Frangipani
defer the cost of writing dirty ﬁle data until the next sync opera-
tion, which may be explicitly requestedby a user or triggered in the
background by a periodic update demon. However, unlike tradi-
tional Unix ﬁle systems, both AdvFS and Frangipani are log-based
and do not write metadata updates synchronously to disk. Instead,
metadata updates are also deferred until the next sync, or at least
until the log wraps.
In order to account properly for all sources of deferred work,
we changed the benchmark to unmount the ﬁle system after each
phase. We choseto unmount rather than to use a sync call because
on Digital Unix, sync queues the dirty data for writing but does
not guarantee it has reached disk before returning. The results,
shown in Table 1, indicate that Frangipani is comparable to AdvFS
in all phases.
Table 2 shows the results of running the Connectathon Bench-
mark. The Connectathon benchmark tests individual operations or
small groups of related operations, providing more insight into the
sources of the differences that are visible in the Andrew bench-
mark. Like the Andrew benchmark, this benchmark also does not
account for deferred work, so again we unmounted the ﬁle system
at the end of each phase.
Frangipani latencies with NVRAM are roughly comparable to
AdvFS
Frangipani
Test
Description
Raw
NVR
Raw
NVR
1
ﬁle and directory creation:
0.92
0.80
3.11
2.37
creates 155 ﬁles and
62 directories.
2
ﬁle and directory removal:
0.62
0.62
0.43
0.43
removes 155 ﬁles and 62
62 directories.
3
lookup across mount point:
0.56
0.56
0.43
0.40
500 getwd and stat calls.
4
setattr, getattr, and lookup:
0.42
0.40
1.33
0.68
1000 chmods and stats
on 10 ﬁles.
5a
write: writes a 1048576
2.20
2.16
2.59
1.63
byte ﬁle 10 times.
5b
read: reads a 1048576
0.54
0.45
1.81
1.83
byte ﬁle 10 times.
6
readdir: reads 20500
0.58
0.58
2.63
2.34
directory entries, 200 ﬁles.
7
link and rename: 200
0.47
0.44
0.60
0.50
renames and links
on 10 ﬁles.
8
symlink and readlink: 400
0.93
0.82
0.52
0.50
symlinks and readlinks
on 10 ﬁles.
9
statfs: 1500 statfs calls.
0.53
0.49
0.23
0.22
Table 2: Connectathon Benchmark with unmount operations.
We run the Connectathon Benchmark with a unmount operation
included at the end of each test. Each table entry is an average
elapsed time in seconds, and smaller numbers are better. Test 5b
is anomalous due to a bug in AdvFS.
that of AdvFS with four notable exceptions. Tests 1, 4, and 6
indicate that creating ﬁles,setting attributes, and reading directories
take signiﬁcantly longer with Frangipani. In practice, however,
these latencies are small enough to be ignored by users, so we have
not tried very hard to optimize them.
File creation takes longer with Frangipani partly because the
128 KB log ﬁlls up several times during this test. If we double the
log size, the times reduce to 0.89 and 0.86 seconds.
Frangipani is much slower on the ﬁle read test (5b). AdvFS
does well on the ﬁle read test because of a peculiar artifact of its
implementation. On each iteration of the read test, the benchmark
makes a system call to invalidate the ﬁle from the buffer cache
before reading it in. The current AdvFS implementation appears
to ignore this invalidation directive. Thus the read test measures
the performance of AdvFS reading from the cacherather than from
disk. When we redid this test with a cold AdvFS ﬁle cache, the
performance was similar to Frangipani’s (1.80 seconds, with or
without NVRAM).
We next report on the throughput achievedby asingle Frangipani
server when reading and writing large ﬁles. The ﬁle reader sits in
a loop reading a set of 10 ﬁles. Before each iteration of the loop,
it ﬂushes the contents of the ﬁles from the buffer cache. The ﬁle
writer sits in a loop repeatedly writing a large (350 MB) private ﬁle.
The ﬁle is large enough that there is a steady stream of write trafﬁc
to disk. Both read and write tests were run for several minutes
and we observed no signiﬁcant variation in the throughput. The
time-averaged, steady state results are summarized in Table 3. The
presence or absence of NVRAM has little effect on the timing.
A single Frangipani machine can write data at about 15.3 MB/s,

--- PDF page 10 ---
Throughput (MB/s)
CPU Utilization
Frangipani
AdvFS
Frangipani
AdvFS
Write
15.3
13.3
42%
80%
Read
10.3
13.2
25%
50%
Table 3: Frangipani Throughput and CPU Utilization.
We
show the performance of Frangipani in reading and writing large
ﬁles.
which is about 96% of the limit imposed by the ATM link and
UDP/IP software on our machine. Frangipani achieves good per-
formance by clustering writes to Petal into naturally aligned 64
KB blocks. It is difﬁcult make up the last 4% because Frangipani
occasionally (e.g., during sync) must write part of the data out in
smaller blocks. Using smaller block sizes reduces the maximum
available throughput through the UDP/IP stack. The Frangipani
server CPU utilization is about 42%, and the Petal server CPUs are
not a bottleneck.
A single Frangipani machine can read data at 10.3 MB/s with
25% CPU utilization.
We believe this performance can be im-
proved by changing the read-ahead algorithm used in Frangipani.
Frangipani currently uses a read-ahead algorithm borrowed from
the BSD-derived ﬁle system UFS, which is less effective than the
one used by AdvFS.
For comparison, AdvFS can write data at about 13.3 MB/s when
accessing large ﬁles that are striped over the eight RZ29 disks
connected to the two controllers. The CPU utilization is about
80%.
The AdvFS read performance is about 13.2 MB/s, at a
CPU utilization of 50%. Neither the CPU nor the controllers are
bottlenecked,so we believe AdvFS performancecould beimproved
a bit with more tuning.
It is interesting to note that although Frangipani uses a simple
policy to lay out data, its latency and write throughput are compa-
rable to those of conventional ﬁle systems that use more elaborate
policies.
Frangipani has good write latency because the latency-critical
metadata updates are logged asynchronouslyrather than being per-
formed synchronously in place. File systems like UFS that syn-
chronously update metadata have to be more careful about data
placement. In separate experiments not described here, we have
found that even when Frangipani updates its logs synchronously,
performance is still quite good becausethe log is allocated in large
physically contiguous blocks and because the NVRAM absorbs
much of the write latency.
Frangipani achieves good write throughput because large ﬁles
are physically striped in contiguous 64 KB units over many disks
and machines, and Frangipani can exploit the parallelism inherent
in this structure. Frangipani has good read throughput for large
ﬁles for the same reason.
Recall from Section 3 that individual 4 KB blocks for ﬁles
smaller than 64 KB may not be allocated contiguously on disk.
Also, Frangipani does not do read-ahead for small ﬁles, so it can-
not always hide the disk seek access times. Thus it is possible that
Frangipani could have bad read performance on small ﬁles. To
quantify small read performance, we ran an experiment where 30
processes on a single Frangipani machine tried to read separate 8
KB ﬁles after invalidating the buffer cache. Frangipani throughput
was 6.3 MB/s, with the CPU being the bottleneck. Petal, accessed
through the raw device interface using 4 KB blocks, can deliver 8
MB/s. Thus Frangipani gets about 80% of the maximum through-
put achievable in this case.
9.3
Scaling
This section studies the scaling characteristics of Frangipani. Ide-
ally, we would like to see operational latencies that are unchanged
and throughput that scales linearly as servers are added.
  Compile
  Scan Files
  Directory Status
 Copy Files
 Create Directories
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
8
|
0
|
10
|
20
|
30
|
40
|
50
 Frangipani Machines
 Elapsed Time (secs)
Figure 5: Frangipani Scaling on Modiﬁed Andrew Benchmark.
Several Frangipani servers simultaneously run the Modiﬁed An-
drew Benchmark on independent data sets. The
  -axis gives the
averageelapsedtime takenby oneFrangipani machineto complete
the benchmark.
Figure 5 shows the effect of scaling on Frangipani running the
Modiﬁed Andrew Benchmark. In this experiment, we measure
the average time taken by one Frangipani machine to complete
the benchmark as the number of machines is increased.
This
experiment simulates the behavior of several users doing program
development on a shareddata pool. We notice that there is minimal
negative impact on the latency as Frangipani machines are added.
In fact, between the single machine and six machine experiment,
the average latency increased by only 8%. This is not surprising
because the benchmark exhibits very little write sharing and we
would expectlatenciesto remain unaffected with increasedservers.
 Read file (Uncached)
 Linear Scaling
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
8
|
0
|
10
|
20
|
30
|
40
|
50
|
60
 Frangipani Machines
 Throughput (MB/s)
Figure 6: Frangipani Scaling on Uncached Read.
Several
Frangipani servers simultaneously read the same set of ﬁles. The
dotted line shows the linear speedup curve for comparison.
Figure 6 illustrates Frangipani’s read throughput on uncached
data. In this test, we replicate the reader from the single-server
experiment on multiple servers. The test runs for several minutes,
and we observe negligible variation in the steady-state throughput.
As indicated in the ﬁgure, Frangipani shows excellent scaling in
this test. We are in the process of installing Frangipani on more
machines, and we expect aggregate read performance to increase
until it saturates the Petal servers’ capacity.
Figure 7 illustrates Frangipani’s write throughput.
Here the
writer from the single-server experiment is replicated on multiple
servers. Each server is given a distinct large ﬁle. The experiment

--- PDF page 11 ---
Write file 
 Linear Scaling
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
8
|
0
|
10
|
20
|
30
|
40
|
50
|
60
 Frangipani Machines
 Throughput (MB/s)
Figure 7: Frangipani Scaling on Write. Each Frangipani server
writes a largeprivate ﬁle. The dotted line shows the linear speedup
curve for comparison. Performance tapers off early because the
ATM links to the Petal servers become saturated.
runs for several minutes, and we observe little variation in the
steady-state throughput during this interval. Since there is no lock
contention in the experiment, the performance is seen to scale well
until the ATM links to the Petal servers are saturated. Since the
virtual disk is replicated, each write from a Frangipani server turns
into two writes to the Petal servers.
9.4
Effects of Lock Contention
Since Frangipani uses coarse-grained locking on entire ﬁles, it is
important to study the effect of lock contention on performance.
We report three experiments here.
The ﬁrst experiment measures the effect of read/write sharing
on ﬁles. One or more readers compete against a single writer for
the same large ﬁle. Initially, the ﬁle is not cached by the readers
or the writer.
The readers read the ﬁle sequentially, while the
writer rewrites the entire ﬁle. As a result, the writer repeatedly
acquires the write lock, then gets a callback to downgrade it so that
the readers can get the read lock. This callback causes the writer
to ﬂush data to disk. At the same time, each reader repeatedly
acquires the read lock, then gets a callback to release it so that the
writer can get the write lock. This callback causes the reader to
invalidate its cache, so its next read after reacquiring the lock must
fetch the data from disk.
 No read-ahead
 With read-ahead
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
0
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
8
 Number of Readers
 Read Throughput (MB/s)
Figure 8: Frangipani Reader/Writer Contention. One or more
Frangipani servers read a shared ﬁle while a single Frangipani
server writes the same ﬁle. We show the effect of read-ahead on
the performance.
The ﬁrst results we observed in this experiment were unex-
pected. Our distributed lock manager has been designed to be
fair in granting locks, and simulations show that this is true of the
implementation. If the single writer and the
 readers were to
make lock requests at a uniform rate, they would be serviced in a
round-robin fashion, so successive grants of the write lock to the
writer would be separated by
 grants of the read lock to the read-
ers. During the interval between two downgrade callbacks, one
would expect the number of read requests and the aggregate read
throughput to increase as readers were added. In the limit when
 is large, the scaling would be linear. However, we did not observe
this behavior in our experiment. Instead, read throughput ﬂattens
out at about 2 MB/s after two readers are running, as shown by the
dashed line in Figure 8. As indicated earlier in Figure 6, this is
only about 10% of what two Frangipani servers can achieve when
there is no lock contention.
We conjectured that this anomalous behavior was caused by
read-ahead, so we repeated the experiment without read-ahead to
check. Read-ahead is disadvantageous in the presence of heavy
read/write contention because when a reader is called back to re-
lease its lock, it must invalidate its cache. If there is any read-ahead
data in the cache that has not yet been delivered to the client, it
must be discarded, and the work to read it turns out to have been
wasted. Because the readers are doing extra work, they cannot
make lock requests at the same rate as the writer. Redoing the
experiment with read-ahead disabled yielded the expected scaling
result, as shown by the solid line in Figure 8.
We couldmakethis performance improvement available to users
either by letting them explicitly disable read-ahead on speciﬁc
ﬁles, or by devising a heuristic that would recognize this case and
disable read-ahead automatically. The former would be trivial to
implement, but would affect parts of the operating system kernel
beyond Frangipani itself, making it inconvenient to support across
future releases of the kernel. The latter approach seems better, but
we have not yet devised or tested appropriate heuristics.

 8 KB

 16 KB

 64 KB
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
0
|
1
|
2
|
3
|
4
|
5
|
6
|
7
|
8
 Number of Readers
 Read Throughput (MB/s)















Figure 9: Effect of Data Size on Reader/Writer Contention.
One or more Frangipani readers share varying amounts of data
with a Frangipani writer. Readahead is disabledin this experiment.
The second experiment is a variation of the ﬁrst.
Here, the
readers run as before, but the writer modiﬁes different amounts of
ﬁle data. Since Frangipani locks entire ﬁles, readers will have to
invalidate their entire cache irrespective of the writer’s behavior.
However, readers will be able to acquire a lock faster when the
writer is updating fewer blocks of data because the writer must
ﬂush only smaller amounts of data to disk. Figure 9 shows the per-
formance of Frangipani (with read-ahead disabled) when readers
and the writer concurrently share differing amounts of data. As ex-
pected, when the shared data is smaller, we get better performance.
The third experiment measuresthe effects of write/write sharing

--- PDF page 12 ---
on ﬁles. As the base case, a Frangipani server writes a ﬁle in
isolation. We then added Frangipani servers that wrote the same
ﬁle and measured the degradation in performance. Writers modify
ﬁle data in blocks of 64 KB. Since Frangipani does whole-ﬁle
locking, the offsets that the writers use are irrelevant for this test.
We found that the aggregate bandwidth seen by all the writers
dropped from 15 MB/s for the single-writer case to a little over 1
MB/s with two or more writers. This is not surprising, because
with multiple writers trying to modify a ﬁle, nearly every write
system call will cause a lock revocation request. This revocation
request causes the lock holder to ﬂush its dirty data to Petal. Since
locks are being revoked on every write system call and each
call dirties only 64 KB of data, throughput is quite limited. With
smaller block sizes, throughput is even smaller.
We do not have much experience with workloads that exhibit
concurrent write sharing. If necessary, we believe it would be
straightforward to extend Frangipani toimplement byte-rangelock-
ing [6] or block locking instead. This would improve the perfor-
mance of workloads that read and write different parts of the same
ﬁle, making it similar to the performance of writing different ﬁles
in the current system. Workloads in which multiple machines con-
currently read and write the same blocks of the same ﬁle—where
the ﬁlesystem is being used as an interprocess communication
channel—would perform as indicated above. Frangipani is simply
not targeted for such workloads.
10
Related Work
Like Frangipani, the Cambridge (or Universal) File Server takes a
two-layered approach to building a ﬁle system [4, 28]. The split
between layers is quite different from ours, however. CFS, the
lower layer, provides its clients with two abstractions: ﬁles and
indices. File systems built above CFS can use these abstractions to
implement ﬁles and directories. A major difference between CFS
and Petal is that in CFS a single machine manages all the storage.
NFS [31, 33] is not a ﬁle system in itself, but simply a remote
ﬁle access protocol. The NFS protocol provides a weak notion
of cache coherence, and its stateless design requires clients to
access servers frequently to maintain even this level of coherence.
Frangipani provides a strongly coherent, single system view, using
a protocol that maintains more state but eliminates unnecessary
accesses to servers.
The Andrew File System (AFS) [19] and its offshoot
DCE/DFS [21] provide better cache performance and coherence
than NFS. AFS is designed for a different kind of scalability than
Frangipani. Frangipani provides a uniﬁed cluster ﬁle system that
draws from a single pool of storage, and can be scaled up to span
many disk drives across many machines under a common admin-
istration. In contrast, AFS has a global name space and security
architecture that allows one to plug in many separate ﬁle servers
and clients over a wide area. We believe the AFS and Frangipani
approaches to scaling are complementary; it would make good
sense for Frangipani servers to export the ﬁle system to wide-area
clients using the AFS or DCE/DFS name space and accessprotocol.
Like Frangipani, the Echo ﬁle system [5, 18, 26, 35] is log-
based,replicates data for reliability and accesspathsfor availability,
permits volumes to span multiple disks, and provides coherent
caching. Echo does not share Frangipani’s scalability, however.
Each Echo volume can be managed by only one server at a time,
with failover to one designated backup. A volume can span only
as many disks as can be connected to a single machine. There is
an internal layering of ﬁle service atop disk service, but the Echo
implementation requires both layers to run in the same address
space on the same machine, and experience with Echo showed the
server CPU to be a bottleneck.
The VMS Cluster ﬁle system [14] ofﬂoads ﬁle system process-
ing to individual machines that are members of a cluster, much as
Frangipani does. Each cluster member runs its own instance of the
ﬁle systemcode on top of a sharedphysical disk, with synchroniza-
tion provided by a distributed lock service. The shared physical
disk is accessed either through a special-purpose cluster intercon-
nect to which a disk controller can be directly connected,or through
an ordinary network such as Ethernet and a machine acting as a
disk server. Frangipani improves upon this design in several ways:
The shared physical disk is replaced by a shared scalable virtual
disk provided by Petal, the Frangipani ﬁle system is log-based for
quick failure recovery, and Frangipani provides extensive caching
of both data and metadata for better performance.
The Spiralog ﬁle system [20] also ofﬂoads its ﬁle system pro-
cessing to individual cluster members, which run above a shared
storage system layer. The interface between layers in Spiralog
differs both from the original VMS Cluster ﬁle system and from
Petal. The lower layer is neither ﬁle-like nor simply disk-like;
instead, it provides an array of stably-stored bytes, and permits
atomic actions to update arbitrarily scattered sets of bytes within
the array. Spiralog’s split between layers simpliﬁes the ﬁle system,
but complicatesthe storage system considerably. At the same time,
Spiralog’s storage system does not share Petal’s scalability or fault
tolerance; a Spiralog volume can span only the disks connected to
one machine, and becomesunavailable when that machine crashes.
Thoughdesignedas a cluster ﬁle system, Calypso [11] is similar
to Echo, not to VMS Clusters or Frangipani. Like Echo, Calypso
stores its ﬁles on multiported disks. One of the machines directly
connected to each disk acts as a ﬁle server for data stored on that
disk; if that machine fails, another takes over. Other members of the
Calypso cluster access the current server as ﬁle system clients. Like
both Frangipani and Echo, the clients have caches, kept coherent
with a multiple-reader/single-writer locking protocol.
For comparison purposes, the authors of Calypso also built a
ﬁle system in the shared-disk style, called PJFS [12].
Calypso
performed better than PJFS, leading them to abandon the shared-
disk approach. PJFS differs from Frangipani in two main respects.
First, its lower layer is a centralized disk server, not a distributed
virtual disk like Petal. Second, all ﬁle server machines in PJFS
share a common log. The shared log proved to be a performance
bottleneck. Like Frangipani, PJFS locks the shared disk at whole-
ﬁle granularity.
This granularity caused performance problems
with workloads where large ﬁles were concurrently write-shared
among multiple nodes. We expect the present Frangipani imple-
mentation to have similar problems with such workloads, but as
noted in Section 9.4 above, we could adopt byte-range locking
instead.
Shillner and Felten have built a distributed ﬁle system on top
of a shared logical disk [34].
The layering in their system is
similar to ours: In the lower layer, multiple machines cooperate
to implement a single logical disk. In the upper layer, multiple
independent machines run the same ﬁle system code on top of one
logical disk, all providing access to the same ﬁles. Unlike Petal,
their logical disk layer does not provide redundancy. The system
can recover when a nodefails and restarts,but it cannot dynamically
conﬁgure out failed nodes or conﬁgure in additional nodes. Their
ﬁle system uses careful ordering of metadata writes, not logging
as Frangipani does. Like logging, their technique avoids the need

--- PDF page 13 ---
for a full metadata scan (fsck) to restore consistency after a server
crash, but unlike logging, it can lose track of free blocks in a crash,
necessitating an occasional garbage collection scan to ﬁnd them
again. We are unable to compare the performance of their system
with ours at present, as performance numbers for their ﬁle system
layer are not available.
The xFS ﬁle system [1, 36] comes closest in spirit to Frangipani.
In fact, the goals of the two systems are essentially the same. Both
try to distribute the management responsibility for ﬁles over mul-
tiple machines and to provide good availability and performance.
Frangipani is effectively “serverless” in the same sense as xFS—
the service is distributed over all machines, and can be conﬁgured
with both a Frangipani server and Petal server on each machine.
Frangipani’s locking is coarser-grained that xFS, which supports
block-level locking.
Our work differs from xFS in two principal ways:
First, the internal organization of our ﬁle system and its interface
to the storage system are signiﬁcantly different from xFS’s. Unlike
Frangipani, xFS has a predesignated manager for each ﬁle, and its
storage server is log-structured. In contrast, Frangipani is orga-
nized as a set of cooperating machines that use Petal as a shared
store with a separate lock service for concurrency control. Ours
is a simpler model, reminiscent of multithreaded shared memory
programs that communicate via a common store and use locks for
synchronization. This model allows us to deal with ﬁle system
recovery and server addition and deletion with far less machinery
than xFS requires, which has made our system easier to implement
and test.
Second, we have addressed ﬁle system recovery and reconﬁgu-
ration. These issues have been left as open problems by the xFS
work to date.
We would have liked to compare Frangipani’s performance with
that of xFS, but considerable performance work remains to be
completed on the current xFS prototype[1]. A comparison between
the systems at this time would be premature and unfair to xFS.
11
Conclusions
The Frangipani ﬁle system provides all its users with coherent,
shared access to the same set of ﬁles, yet is scalable to provide
more storage space, higher performance, and load balancing as the
user community grows. It remains available in spite of component
failures. It requires little humanadministration, and administration
does not become more complex as more components are added to
a growing installation.
Frangipani was feasible to build because of its two-layer struc-
ture, consisting of multiple ﬁle servers running the same simple
ﬁle system code on top of a shared Petal virtual disk. Using Petal
as a lower layer provided several beneﬁts. Petal implements data
replication for high availability, obviating the need for Frangipani
to do so. A Petal virtual disk is uniformly accessible to all Frangi-
pani servers, so that any server can serve any ﬁle, and any machine
can run recovery when a server fails. Petal’s large, sparse address
space allowed us to simplify Frangipani’s on-disk data structures.
Despite Frangipani’s simple data layout and allocation policy
and coarse-grained locking, we have been happy with its perfor-
mance. In our initial performance measurements, Frangipani is
already comparable to a production DIGITAL Unix ﬁle system,
and we expect improvement with further tuning. Frangipani has
shown good scaling properties up to the size of our testbed conﬁg-
uration (seven Petal nodes and six Frangipani nodes). The results
leave us optimistic that the system will continue to scale up to many
more nodes.
Our future plans include deploying Frangipani for our own day-
to-day use. We hope to gain further experience with the prototype
under load, to validate its scalability by testing it in larger conﬁgu-
rations, to experiment with ﬁner-grained locking, and to complete
our work on backup. Finally, of course, we would like to see the
ideas from Frangipani make their way into commercial products.
Acknowledgments
We thank Mike Burrows, Mike Schroeder, and Puneet Kumar for
helpful advice on the Frangipani design and comments on this
paper. Fay Chang implemented an early prototype of Frangipani
as a summer project. The anonymous referees and our shepherd,
John Wilkes, suggested many improvements to the paper. Cynthia
Hibbard provided editorial assistance.
References
[1] Thomas E. Anderson, Michael D. Dahlin, Jeanna M. Neefe,
David A. Patterson, Drew S. Roselli, and Randolph Y. Wang.
Serverless network ﬁle systems. ACM Transactionson Com-
puter Systems, 14(1):41–79, February 1996.
[2] Philip A. Bernstein, Vassos Hadzilacos, and Nathan Good-
man. Concurrency Control and Recovery in Database Sys-
tems. Addison-Wesley, 1987.
[3] Anupam Bhide, Elmootazbellah N. Elnozahy, and Stephen P.
Morgan.
A highly available network ﬁle server.
In Pro-
ceedings of the Winter USENIX Conference, pages 199–205,
January 1991.
[4] A. D. Birrell and R. M. Needham. A universal ﬁle server.
IEEE Transactions on Software Engineering, SE-6(5):450–
453, September 1980.
[5] Andrew D. Birrell, Andy Hisgen, Charles Jerian, Timothy
Mann, and Garret Swart.
The Echo distributed ﬁle sys-
tem. Research Report 111, Systems ResearchCenter, Digital
Equipment Corporation, September 1993.
[6] Michael Burrows. Efﬁcient Data Sharing. PhD thesis, Uni-
versity of Cambridge, September 1988.
[7] C. Chao, R. English, D. Jacobson,A. Stepanov,andJ. Wilkes.
Mime:
A high performance parallel storage device with
strong recovery guarantees. Technical Report HPL-CSP-92-
9, Hewlett-Packard Laboratories, November 1992.
[8] Jeffrey S. Chase, Henry M. Levy, Michael J. Feeley, and
Edward D. Lazowska. Sharing and protection in a single-
address-spaceoperating system. ACM Transactionson Com-
puter Systems, 12(4):271–307, November 1994.
[9] Sailesh Chutani, Owen T. Anderson, Michael L. Kazar,
Bruce W. Leverett, W. Anthony Mason, and Robert N. Side-
botham. The Episode ﬁle system. In Proceedings of the
Winter USENIX Conference, pages 43–60, January 1992.
[10] Wiebren de Jonge, M. Frans Kaashoek, and Wilson C. Hsieh.
The logical disk: A new approach to improving ﬁle systems.
In Proc. 14th Symp. on Operating Systems Principles, pages
15–28, December 1989.

--- PDF page 14 ---
[11] Murthy Devarakonda, Bill Kish, and Ajay Mohindra. Re-
covery in the Calypso ﬁle system. ACM Transactions on
Computer Systems, 14(3):287–310, August 1996.
[12] Murthy Devarakonda, Ajay Mohindra, Jill Simoneaux, and
William H. Tetzlaff. Evaluation of design alternatives for a
cluster ﬁle system. In Proceedings of the Winter USENIX
Conference, pages 35–46, January 1995.
[13] Garth A. Gibson, David F. Nagle, Khalil Amiri, Fay W.
Chang, Eugene M. Feinberg, Howard Gobioff, Chen Lee,
Berend Ozceri, Erik Riedel, David Rochberg, and Jim Ze-
lenka. File server scaling with network-attachedsecuredisks.
In Proceedings of the ACM International Conference on Mea-
surements and Modeling of Computer Systems (Sigmetrics
’97), pages 272–284, June 1997.
[14] Andrew C. Goldstein. The design and implementation of a
distributed ﬁle system. Digital Technical Journal, 1(5):45–
55, September 1987.
Digital Equipment Corporation, 50
Nagog Park, AK02-3/B3, Acton, MA 01720-9843.
[15] Cary Gray and David Cheriton. Leases: An efﬁcient fault-
tolerant mechanism for distributed ﬁle cache consistency. In
Proc. 12th Symp. on Operating Systems Principles, pages
202–210, December 1989.
[16] Robert Hagmann. Reimplementing the Cedar ﬁle system
using logging and group commit. In Proc. 11th Symp. on
Operating Systems Principles, pages 155–162, November
1987.
[17] John H. Hartman and John K. Ousterhout. The Zebra striped
network ﬁle system. ACM Transactions on Computer Sys-
tems, 13(3):274–310, August 1995.
[18] Andy Hisgen, Andrew Birrell, Charles Jerian, Timothy
Mann, and Garret Swart. New-value logging in the Echo
replicated ﬁle system. Research Report 104, Systems Re-
search Center, Digital Equipment Corporation, June 1993.
[19] John H. Howard, Michael L. Kazar, Sherri G. Menees,
David A. Nichols, M. Satyanarayanan, Robert N. Side-
botham, and Michael J. West.
Scale and performance in
a distributed ﬁle system. ACM Transactions on Computer
Systems, 6(1):51–81, February 1988.
[20] James E. Johnson and William A. Laing. Overview of the
Spiralog ﬁle system. Digital Technical Journal, 8(2):5–14,
1996. Digital Equipment Corporation,50 Nagog Park,AK02-
3/B3, Acton, MA 01720-9843.
[21] Michael L. Kazar, Bruce W. Leverett, Owen T. Anderson,
Vasilis Apostolides, Ben A. Bottos, Sailesh Chutani, Craig F.
Everhart, W. Antony Mason, Shu-Tsui Tu, and Edward R.
Zayas. DEcorum ﬁle system architectural overview. In Pro-
ceedings of theSummerUSENIX Conference,pages 151–164,
June 1990.
[22] Nancy P. Kronenberg, Henry M. Levy, and William D.
Strecker. VAXclusters: A closely-coupled distributed sys-
tem. ACM Transactions on Computer Systems,4(2):130–146,
May 1986.
[23] Leslie Lamport. The part-time parliament. Research Re-
port 49, Systems Research Center, Digital Equipment Cor-
poration, September 1989.
[24] Edward K. Lee and ChandramohanA. Thekkath. Petal: Dis-
tributed virtual disks. In Proc. 7th Intl. Conf. on Architec-
tural Support for Programming Languages and Operating
Systems, pages 84–92, October 1996.
[25] Barbara Liskov, Sanjay Ghemawat, Robert Gruber, Paul
Johnson, Liuba Shrira, and Michael Williams. Replication
in the Harp ﬁle system. In Proc. 13th Symp. on Operating
Systems Principles, pages 226–238, October 1991.
[26] Timothy Mann, Andrew Birrell, Andy Hisgen, Charles Je-
rian, and Garret Swart. A coherent distributed ﬁle cache with
directory write-behind. ACM Transactionson Computer Sys-
tems, 12(2):123–164, May 1994.
[27] Marshal Kirk McKusick, William N. Joy, Samuel J. Lefﬂer,
and Robert S. Fabry. A fast ﬁle system for UNIX. ACM
Transactions on Computer Systems, 2(3):181–197, August
1984.
[28] James G. Mitchell and Jeremy Dion. A comparison of two
network-based ﬁle servers. Communications of the ACM,
25(4):233–245, April 1982.
[29] Sape J. Mullender and Andrew S. Tanenbaum. Immediate
ﬁles. Software—Practice and Experience, 14(4):365–368,
April 1984.
[30] Michael N. Nelson, Brent B. Welch, and John K. Ousterhout.
Caching in the Sprite network ﬁle system. ACM Transactions
on Computer Systems, 6(1):134–154, February 1988.
[31] Brian Pawlowski, Chet Juszczak,Peter Staubach,Carl Smith,
Diane Lebel, and David Hitz. NFS version 3 design and
implementation.
In Proceedings of the Summer USENIX
Conference, pages 137–152, June 1994.
[32] Mendel Rosenblum and John K. Ousterhout.
The design
and implementation of a log-structured ﬁle system. ACM
Transactions on Computer Systems, 10(1):26–52, February
1992.
[33] Russel Sandberg, David Goldberg, Steve Kleiman, Dan
Walsh, and Bob Lyon. Design and implemention of the Sun
network ﬁlesystem. In Proceedings of the Summer USENIX
Conference, pages 119–130, June 1985.
[34] Robert A. Shillner and Edward W. Felten. Simplifying dis-
tributed ﬁle systems using a shared logical disk. Technical
Report TR-524-96, Dept. of Computer Science, Princeton
University, 1996.
[35] Garret Swart, Andrew Birrell, Andy Hisgen, Charles Jerian,
and Timothy Mann. Availability in the Echo ﬁle system. Re-
search Report 112, Systems Research Center, Digital Equip-
ment Corporation, September 1993.
[36] Randy Wang, Tom Anderson, and Mike Dahlin. Experience
with a distributed ﬁle system implementation. Technical re-
port, University of California, Berkeley, Computer Science
Division, June 1997.
[37] Edward Wobber, Martin Abadi, Michael Burrows, and Butler
Lampson. Authentication in the Taos operating system. ACM
Transactions on Computer Systems, 12(1):3–32, February
1994.

### faq: FAQ

- URL: http://nil.csail.mit.edu/6.824/2021/papers/frangipani-faq.txt
- Local path: official-materials/faqs/frangipani-faq.txt

#### Archived Content

FAQ for Frangipani, Thekkath, Mann, Lee, SOSP 1997

Q: Why are we reading this paper?

A: Primarily as an illustration of cache coherence.

But there are other interesting aspects. The idea of each client
having its own log, stored in a public place so that anyone can
recover from it, is clever. Further, the logs are intertwined in an
unusual way: the updates to a given object may be spread over many
logs. This makes replaying a single log tricky (hence Frangipani's
version numbers). Building a system out of simple shared storage
(Petal) and smart but decentralized participants is interesting,
particularly recovery from the crash of one participant.

Q: How does Frangipani differ from GFS?

A: A big architectural difference is that GFS has most of the file
system logic in the servers, while Frangipani distributes the logic
over the workstations that run Frangipani. That is, Frangipani doesn't
really have a notion of file server in the way that GFS does, only
file clients. Frangipani puts the file system logic in the clients in
order to allow them to perform file system operations purely in their
local caches. This makes sense when most activity is client
workstations reading and writing a single user's (cached) files.
Frangipani has a lot of mechanism to ensure that workstation caches
stay coherent, both so that a write on one workstation is immediately
visible to a read on another workstation, and so that complex
operations (like creating a file) are atomic even if other
workstations are trying to look at the file or directory involved.
This last situation is tricky for Frangipani because there's no
designated file server that executes all operations on a given file or
directory.

In contrast, GFS doesn't have caches at all, since its focus is
sequential read and write of giant files that are too big to fit in
any cache. It gets high performance for reads of giant files by
striping each file over many GFS servers. Because GFS has no caches,
GFS does not have a cache coherence protocol. Because the file system
logic is in the servers, GFS clients are relatively simple; only the
servers need to have locking and worry about crash recovery.

Frangipani appears as a real file system that you can use with any
existing workstation program. GFS doesn't present as a file system in
that sense; applications have to be written explicitly to use GFS via
library calls.

Q: Why do the Petal servers in the Frangipani system have a block
interface? Why not have file servers (like AFS), that know about
things like directories and files?

One reason is that the authors developed Petal first. Petal already
solved many fault tolerance and scaling problems, so using it
simplified some aspects of the Frangipani design. And this arrangement
moves work from centralized servers to client workstations, which
helps Frangipani performance scale well as more workstations are
added.

However, the Petal/Frangipani split makes enforcing invariants on
file-system-level structures harder, since no one entity is in charge.
Frangipani builds its own transaction system (using the lock service
and Frangipani's logs) in order to be able to make complex atomic
updates to the file system stored in Petal.

Q: Can a workstation running Frangipani break security?

A: Yes. Since the file system logic is in the client workstations, the
design places trust in the clients. A user could modify the local
Frangipani software and read/write other users' data in Petal. This
makes Frangipani unattractive if users are not trusted. It might still
make sense in a small organization, or if Frangipani ran on separate
dedicated servers (not on workstations) and talked to user
workstations with a protocol like NFS.

Q: What is Digital Equipment Corporation (DEC)?

A: It's the company at which the authors worked. DEC sold computers
and systems software. Unix was originally developed on DEC hardware
(though at Bell Labs, not at Digital).

Q: What does the comment "File creation takes longer..." in Section
9.2 mean?

A: Because of logging, all meta-data changes have to be written to
Petal twice: once to the log, and once to the file system. An
operation must be written to the log first (thus "write-ahead log").
Then the on-disk file system structures can be written. Only after
that can the operation be deleted from the log. That is, a portion of
the log can only be freed after all the on-disk file system updates
from the operations in that portion have been written to Petal.

So when Frangipani's log fills, Frangipani has to stop processing new
operations, send modified blocks from its cache to Petal for the
operations in the portion of the log it wants to re-use, and only then
free that portion and resume processing new operations.

You might wonder why increasing the log size improved performance.
After all, Frangipani has to perform the updates to the file system in
Petal no matter how long the log is, and those updates seem to be the
limiting performance factor. Here's a guess. It's probably the case
that the benchmark involves updating the same directory many times, to
add new files to that directory. That directory's blocks will have to
be written to Petal every time part of the log is freed (assuming
every creation modifies the one directory). So letting the log grow
longer reduces the total number of times that directory has to be
written to Petal during the benchmark, which decreases benchmark
running time. This effect is called "write absorbtion."

Q: Frangipani is over 20 years old now; what's the state-of-the-art in
distributed file systems?

A: While some organizations today store user and project files on
distributed file systems, their importance has waned with the rise of
laptops (which must be self-contained) and commercial cloud services.
Still, there are many users of existing file-system protocols such as
SMB, NFS, and AFS, as well as more recent distributed file-systems
like xtreemfs, Ceph, Lustre, and Dropbox. A huge amount of network
storage is sold by companies like NetAPP and EMC, but I don't know to
what extent people use the storage at the disk level (via e.g. iSCSI)
or as file servers (e.g. talking to a NetAPP server with NFS).

The rise of web sites, big data, and cloud computing have shifted the
focus of storage system development. Web sites work well with
database-like servers, including key/value stores; file servers are
not a good match here. Big data processing systems often use file
systems, e.g. GFS for MapReduce, but the focus is on high parallel
through for huge files; Frangipani's caching, coherence, and locking
are not needed.

Q: The paper says Frangipani only does crash recovery for its own file
system meta-data (i-nodes, directories, free bitmaps), but not for
users' file content. What does that mean, and why is it OK?

A: If a user on a workstation writes some data to a file on
Frangipani, and then the workstation immediately crashes, the recently
written data may be lost. That is, if the user logs into another
workstation and looks at the file, the recently written data may be
missing.

Ordinary Unix file systems (e.g. Linux on a laptop) have the same
property: file content written just before a crash may be lost.

Programs that care about crash recovery (e.g. text editors and
databases) can ask Unix to be more careful, at some expense in
performance. In particular, an application can call fsync(), which
tells Unix to force the data to disk immediately so that it will
survive a crash. The paper mentions fsync() in Section 2.1.

The rationale here is that the file system carefully defends its own
internal invariants (on its own meta-data), since otherwise the file
system might not be usable at all after a crash. But the file system
leaves maintaining of invariants in file content up to applications,
since only the application knows which data must be carefully (and
expensively) written to disk right away.

Q: What's the difference between the log stored in the Frangipani
workstation and the log stored on Petal?

The Petal paper hardly mentions Petal's log at all. My guess is that
Petal logs changes to the mapping from logical block number to
physical block number, changes the physical block free list, and
changes to the "busy" bits that indicate which block updates the other
replica of the block may be missing. That is, Petal logs information
about low-level block operations.

Frangipani logs information about file system operations, which often
involve updating multiple pieces of file system state in Petal. For
example, a Frangipani log entry for deleting a file may say that the
delete operation modified some block and i-node free bitmap bits, and
that the operation erased a particular directory entry.

Both of the logs are stored on Petal's disks. From Petal's point of
view, Frangipani's logs are just data stored in Petal blocks; Petal does
not know anything special about Frangipani's logs.

Q: How does Petal take efficient snapshots of the large virtual disk that
it represents?

A: Petal maintains a mapping from virtual to physical block numbers. The
mapping is actually indexed by a pair: the virtual block number and an
epoch number. There is also a notion of the current epoch number. When
Petal performs a write to a virtual block, it looks at the epoch number
of the current mapping; if the epoch number is less than the current
epoch number, Petal creates a new mapping (and allocates a new physical
block) with the current epoch. A read for a virtual block uses the
mapping with the highest epoch.

Creating a snapshot then merely requires incrementing the current epoch
number. Reading from a snapshot requires the epoch number of the
snapshot to be specified; then each read uses the mapping for the
requested virtual block number that has the highest epoch number <= the
snapshot epoch.

Have a look at Section 2.2 of the Petal paper:

http://www.scs.stanford.edu/nyu/02fa/sched/petal.pdf

Q: The paper says that Frangipani doesn't immediately send new log
entries to Petal. What happens if a workstation crashes after
a system call completes, but before it send the corresponding
log entry to Petal?

A: Suppose an application running on a Frangipani workstation creates
a file. For a while, the information about the newly created file
exists only in the cache (in RAM) of that workstation. If the workstation
crashes before it writes the information to Petal, the new file is
completely lost. It won't be recovered.

So application that looks like

  create file x;
  print "I created file x";

might print "I created file x", but (if it then crashes) file x might
nevertheless not exist.

This may seem unfortunate, but it's fairly common even for local disk
file systems such as Linux. An application that needs to be sure its
data is really permanently saved can call fsync().

Q: What does it mean to stripe a file? Is this similar to sharding? 

A: It's similar to sharding. More specifically it means to distribute
the blocks of a single file over multiple servers (Petal server, for
this paper), so that (for example) the file's block 0 goes on server
0, block 1 goes on server 1, block 2 goes on server 0, block 3 goes on
server 1, &c. One reason to do this is to get high performance for
reads of a single big file, since different parts of the same file can
be read from different servers/disks. Another reason is to ensure that
load is balanced evenly over the servers.

Q: What is the "false sharing" problem mentioned in the paper?

A: The system reads and writes Petal at the granularity of a 512-byte
block. If it stored unrelated items X and Y on the same 512-byte
block, and one workstation needed to modify X while another needed to
modify Y, they would have to bounce the single copy of the block back
and forth between them. Because there's not a way to ask Petal to
write less than 512 bytes at a time. It's sharing because both
workstations are using the same block; it's false because they don't
fundamentally need to.

Q: I don’t understand the section 4 text about how Frangipani enforces
the stronger condition of never replaying a completed update.

Here's an example of the problem. Suppose workstation WS1 creates file
xxx, then deletes it. After that, a different workstation WS2 creates
file xxx. Their logs will look like this:

WS1:  create(xxx)  delete(xxx)
WS2:                           create(xxx)

At this point, correctness requires that xxx exist (since WS2's create
came after WS1's delete).

Now suppose WS1 crashes, and Frangipani recovery replays WS1's log.
Recovery will see the delete(xxx) operation in the log. We know that it
would be incorrect to actually do the delete, because we know that WS2's
create(xxx) came after WS1's delete(xxx). But how does Frangipani's
recovery software conclude that it should ignore the delete(xxx) when
replaying WS1's log?

Section 4 is saying that Frangipani's recovery software knows to ignore
the delete(xxx) because it "never replays a log record desccribing an
update that has already been completed." It achieves this property by
keeping a version number in every block of meta-data, and in every log
entry; if the log entry's version number is <= the meta-data block's
version number, Frangipani recovery knows that the meta-data block has
already been updated by the log entry, and thus that the log entry
should be ignored.

Q: How much performance improvement could Frangipani get from having a
separate lock for each block in each file?

A: It would probably be bad for performance. It would presumably mean
that reading a file would require acquiring a lock for each block --
thus much more work for the workstation and the lock server. And there
might be no upside in practice, because there are few applications
that do read/write sharing at the level of file blocks, and thus could
benefit from different workstations being able to modify different
blocks of the same file at the same time. It's much more common to see
sharing at the level of whole files -- as when your editor writes out
the whole file, and then your compiler reads the whole file.

Q: Frangipani and two-phase commit systems both provide distributed
transactions. Are they equivalent -- can one view Frangipani as having
two-phase commit buried in it? Or are there significant differences?

Frangipani and two-phase commit have similarities. In both cases, in
order to perform an operation, all the relevant locks must be
acquired, all the relevant data must be gathered, everything must be
logged, and only then can locks be released. The big difference is
where these things happen. In Frangipani, the locks and data are
movable, and are collected on the Frangipani server that's executing
the operation. In two-phase commit, the data (with associated locks
and logs) are sharded over the servers, so the work has to be split up
the same way.

A significant difference is that Frangipani has a story for how to
proceed if a server crashes while holding locks -- each Frangipani
server's log is in Petal, so another server can recover for it.
Classical two-phase commit places a server's log on its local disk, so
it's not accessible if the server crashes, so progress is not possible
(and locks can't be released) until the server comes back to life.

Another approach to recovery is to replicate each participating
two-phase-commit server (including locks, logs, and data) using e.g.
Paxos, effectively eliminating crashed servers as a concern. Spanner
does this.

### homework: Question

- URL: http://nil.csail.mit.edu/6.824/2021/questions.html?q=q-frangipani&lec=12
- Local path: official-materials/questions/12-q-frangipani.html

#### Assigned Question

Frangipani: A Scalable Distributed File System : Suppose a server modifies an i-node, appends the modification to its log, then another server modifies the same i-node, and then the first server crashes. The recovery system will see the i-node modification in the crashed server's log, but should not apply that log entry to the i-node, because that would un-do the second server's change. How does Frangipani avoid or cope with this situation?
