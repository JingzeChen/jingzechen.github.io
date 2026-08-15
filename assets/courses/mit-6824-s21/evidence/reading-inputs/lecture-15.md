# Reading Input: Lecture 15 - Optimistic Concurrency Control (FaRM)

> This is a generated evidence bundle, not a finished study guide.
> Keep assigned reading ranges and source boundaries when summarizing.

## Video Sessions

- Part 15: Lecture 15 - Optimistic Concurrency Control (FaRM) (https://www.bilibili.com/video/BV16f4y1z7kn/?p=15)
- Part 16: Lecture 15 continued - Optimistic Concurrency Control (FaRM) pt. 2 (https://www.bilibili.com/video/BV16f4y1z7kn/?p=16)

## Resources

### paper: FaRM (2015)

- URL: http://nil.csail.mit.edu/6.824/2021/papers/farm-2015.pdf
- Local path: official-materials/papers/farm-2015.pdf

#### Archived Content


--- PDF page 1 ---
No compromises: distributed transactions with
consistency, availability, and performance
Aleksandar Dragojevi´c, Dushyanth Narayanan, Edmund B. Nightingale,
Matthew Renzelmann, Alex Shamis, Anirudh Badam, Miguel Castro
Microsoft Research
Abstract
Transactions with strong consistency and high availability
simplify building and reasoning about distributed systems.
However, previous implementations performed poorly. This
forced system designers to avoid transactions completely,
to weaken consistency guarantees, or to provide single-
machine transactions that require programmers to partition
their data. In this paper, we show that there is no need to
compromise in modern data centers. We show that a main
memory distributed computing platform called FaRM can
provide distributed transactions with strict serializability,
high performance, durability, and high availability. FaRM
achieves a peak throughput of 140 million TATP transac-
tions per second on 90 machines with a 4.9 TB database, and
it recovers from a failure in less than 50 ms. Key to achiev-
ing these results was the design of new transaction, replica-
tion, and recovery protocols from ﬁrst principles to leverage
commodity networks with RDMA and a new, inexpensive
approach to providing non-volatile DRAM.
1.
Introduction
Transactions with high availability and strict serializabil-
ity [35] simplify programming and reasoning about dis-
tributed systems by providing a simple, powerful abstrac-
tion: a single machine that never fails and that executes one
transaction at a time in an order consistent with real time.
However, prior attempts to implement this abstraction in a
distributed system resulted in poor performance. Therefore,
systems such as Dynamo [13] or Memcached [1] improve
performance by either not supporting transactions or by im-
plementing weak consistency guarantees. Others (e.g., [3–
Permission to make digital or hard copies of part or all of this work for personal or
classroom use is granted without fee provided that copies are not made or distributed
for proﬁt or commercial advantage and that copies bear this notice and the full citation
on the ﬁrst page. Copyrights for third-party components of this work must be honored.
For all other uses, contact the owner/author(s).
SOSP’15,
October 4–7, 2015, Monterey, CA.
Copyright is held by the owner/author(s).
ACM 978-1-4503-3834-9/15/10.
http://dx.doi.org/10.1145/2815400.2815425
6, 9, 28]), provide transactions only when all the data resides
within a single machine, forcing programmers to partition
their data and complicating reasoning about correctness.
This paper demonstrates that new software in modern
data centers can eliminate the need to compromise. It de-
scribes the transaction, replication, and recovery protocols in
FaRM [16], a main memory distributed computing platform.
FaRM provides distributed ACID transactions with strict se-
rializability, high availability, high throughput and low la-
tency. These protocols were designed from ﬁrst principles
to leverage two hardware trends appearing in data centers:
fast commodity networks with RDMA and an inexpensive
approach to providing non-volatile DRAM. Non-volatility
is achieved by attaching batteries to power supply units and
writing the contents of DRAM to SSD when the power fails.
These trends eliminate storage and network bottlenecks, but
they also expose CPU bottlenecks that limit their perfor-
mance beneﬁt. FaRM’s protocols follow three principles to
address these CPU bottlenecks: reducing message counts,
using one-sided RDMA reads and writes instead of mes-
sages, and exploiting parallelism effectively.
FaRM scales out by distributing objects across the ma-
chines in a data center while allowing transactions to span
any number of machines. Rather than replicate coordi-
nators and data partitions using Paxos (e.g., as in [11]),
FaRM reduces message counts by using vertical Paxos [25]
with primary-backup replication, and unreplicated coordina-
tors that communicate directly with primaries and backups.
FaRM uses optimistic concurrency control with a four phase
commit protocol (lock, validation, commit backup, and com-
mit primary) [16] but we improved the original protocol by
eliminating the messages to backups in the lock phase.
FaRM further reduces CPU overhead by using one-sided
RDMA operations. One-sided RDMA uses no remote CPU
and it avoids most local CPU overhead. FaRM transactions
use one-sided RDMA reads during transaction execution
and validation. Therefore, they use no CPU at remote read-
only participants. Additionally, coordinators use one-sided
RDMA when logging records to non-volatile write-ahead
logs at the replicas of objects modiﬁed in a transaction. For
54

--- PDF page 2 ---
example, the coordinator uses a single one-sided RDMA to
write a commit record to a remote backup. Hence, transac-
tions use no foreground CPU at backups. CPU is used later
in the background when lazily truncating logs to update ob-
jects in-place.
Using one-sided RDMA requires new failure-recovery
protocols. For example, FaRM cannot rely on servers to
reject incoming requests when their leases [18] expire be-
cause requests are served by the NICs, which do not sup-
port leases. We solve this problem by using precise member-
ship [10] to ensure that machines agree on the current con-
ﬁguration membership and send one-sided operations only
to machines that are members. FaRM also cannot rely on
traditional mechanisms that ensure participants have the re-
sources necessary to commit a transaction during the prepare
phase because transaction records are written to participant
logs without involving the remote CPU. Instead, FaRM uses
reservations to ensure there is space in the logs for all the
records needed to commit and truncate a transaction before
starting the commit.
The failure recovery protocol in FaRM is fast because it
leverages parallelism effectively. It distributes recovery of
every bit of state evenly across the cluster and it parallelizes
recovery across cores in each machine. In addition, it uses
two optimizations to allow transaction execution to proceed
in parallel with recovery. First, transactions begin accessing
data affected by a failure after a lock recovery phase that
takes only tens of milliseconds to complete rather than wait
several seconds for the rest of recovery. Second, transactions
that are unaffected by a failure continue executing without
blocking. FaRM also provides fast failure detection by lever-
aging the fast network to exchange frequent heart-beats, and
it uses priorities and pre-allocation to avoid false positives.
Our experimental results show that you can have it all:
consistency, high availability, and performance. FaRM re-
covers from single machine failures in less than 50 ms and
it outperforms state-of-the-art single-machine in-memory
transactional systems with just a few machines. For exam-
ple, it achieves better throughput than Hekaton [14, 26]
when running on just three machines and it has both better
throughput and latency than Silo [39, 40].
2.
Hardware trends
FaRM’s design is motivated by the availability of plentiful,
cheap DRAM in data center machines. A typical data center
conﬁguration has 128–512 GB of DRAM per 2-socket ma-
chine [29], and DRAM costs less than $12/GB1. This means
that a petabyte of DRAM requires only 2000 machines, and
this is sufﬁcient to hold the data sets of many interesting ap-
plications. In addition, FaRM exploits two hardware trends
to eliminate storage and network bottlenecks: non-volatile
DRAM, and fast commodity networks with RDMA.
1 16 GB DDR4 DIMMs on newegg.com, 21 March 2015.
1 SSD
2 SSDs
3 SSDs
4 SSDs
0
20
40
60
80
100
120
Energy required (J/GB)
Figure 1. Energy to copy one GB from DRAM to SSD
2.1
Non-volatile DRAM
A “distributed uninterruptible power supply (UPS)” exploits
the wide availability of Lithium-ion batteries to lower the
cost of a data center UPS over a traditional, centralized
approach that uses lead-acid batteries. For example, Mi-
crosoft’s Open CloudServer (OCS) speciﬁcation includes
Local Energy Storage (LES) [30, 36], which integrates Li-
ion batteries with the power supply units in each 24-machine
chassis within a rack. The estimated LES UPS cost is less
than $0.005 per Joule.2 This approach is more reliable than
a traditional UPS: Li-ion batteries are overprovisioned with
multiple independent cells, and any battery failure impacts
only a portion of a rack.
A distributed UPS effectively makes DRAM durable.
When a power failure occurs, the distributed UPS saves the
contents of memory to a commodity SSD using the energy
from the battery. This not only improves common-case per-
formance by avoiding synchronous writes to SSD, it also
preserves the lifetime of the SSD by writing to it only when
failures occur. An alternative approach is to use non-volatile
DIMMs (NVDIMMs), which contain their own private ﬂash,
controller and supercapacitor (e.g., [2]). Unfortunately, these
devices are specialized, expensive, and bulky. In contrast,
a distributed UPS uses commodity DIMMs and leverages
commodity SSDs. The only additional cost is the reserved
capacity on the SSD and the UPS batteries themselves.
Battery provisioning costs depend on the energy required
to save memory to SSDs. We measured an unoptimized pro-
totype on a standard 2-socket machine. On failure, it turns
off the HDDs and NIC and saves in-memory data to a sin-
gle M.2 (PCIe) SSD, and it consumes 110 Joules per GB of
data saved. Roughly 90 Joules is used to power the two CPU
sockets on the machine during the save. Additional SSDs
reduce the time to save data and therefore the energy con-
sumed (Figure 1). Optimizations, like putting the CPUs into
a low-power state, will further reduce energy consumption.
In the worst-case conﬁguration, (single SSD, no opti-
mization) at $0.005 per Joule, the energy cost of non-
2 Li-ion is 5x cheaper than traditional lead-acid based UPS, which costs $31
million per 25 MW data center. A 25 MW data center can house 100,000
machines, and hence the Li-ion UPS cost per machine is $62. A 24-machine
chassis has 6 PSUs, each with an LES that is provisioned for at least 1600 W
for 5 seconds and 1425 W for a further 30 seconds, i.e. a total of 50 kJ per
PSU or 12.5 kJ per machine, giving a cost per Joule of $0.0048.
55

--- PDF page 3 ---
8
16
32
64
128
256
512
1024 2048
Transfer size (bytes)
0
5
10
15
20
Operations / µs / machine 
RDMA
RPC
Figure 2. Per-machine RDMA and RPC read performance
volatility is $0.55/GB and the storage cost of reserving SSD
capacity is $0.90/GB3. The combined additional cost is less
than 15% of the base DRAM cost, which is a signiﬁcant
improvement over NVDIMMs that cost 3–5x as much as
DRAM. Therefore, it is feasible and cost-effective to treat all
machine memory as non-volatile RAM (NVRAM). FaRM
stores all data in memory, and considers it durable when it
has been written to NVRAM on multiple replicas.
2.2
RDMA networking
FaRM uses one-sided RDMA operations where possible be-
cause they do not use the remote CPU. We based this deci-
sion both on our prior work and on additional measurements.
In [16], we showed that on a 20-machine RoCE [22] clus-
ter, RDMA reads performed 2x better than a reliable RPC
over RDMA when all machines read randomly chosen small
objects from the other machines in the cluster. The bottle-
neck was the NIC message rate and our implementation of
RPC requires twice as many messages as one-sided reads.
We replicated this experiment on a 90-machine cluster where
each machine has two Inﬁniband FDR (56 Gbps) NICs. This
more than doubles the message rate per machine when com-
pared with [16] and eliminates the NIC message rate bottle-
neck. Both RDMA and RPC are now CPU bound and the
performance gap increases to 4x, as seen in Figure 2.This il-
lustrates the importance of reducing CPU overhead to realize
the potential of the new hardware.
3.
Programming model and architecture
FaRM provides applications with the abstraction of a global
address space that spans machines in a cluster. Each machine
runs application threads and stores objects in the address
space. The FaRM API [16] provides transparent access to
local and remote objects within transactions. An application
thread can start a transaction at any time and it becomes the
transaction’s coordinator. During a transaction’s execution,
the thread can execute arbitrary logic as well as read, write,
allocate, and free objects. At the end of the execution, the
thread invokes FaRM to commit the transaction.
FaRM transactions use optimistic concurrency control.
Updates are buffered locally during execution and only made
3 Samsung M.2 256 GB MLC, newegg.com on 25 March 2015
FARM
Application
Region
Tx log
Tx log
Machine C 
Machine B 
Machine D 
(CM) 
Machine A 
CPU
NVRAM
Tx records
Tx records
Remote 
reads
Lease
renewals
Local reads
Co-ordination 
service 
(Zookeeper) 
Msg queue
Messages
Figure 3. FaRM architecture
visible to other transactions on a successful commit. Com-
mits can fail due to conﬂicts with concurrent transactions
or failures. FaRM provides strict serializability [35] of all
successfully committed transactions. During transaction ex-
ecution, FaRM guarantees that individual object reads are
atomic, that they read only committed data, that successive
reads of the same object return the same data, and that reads
of objects written by the transaction return the latest value
written. It does not guarantee atomicity across reads of dif-
ferent objects but, in this case, it guarantees that the trans-
action does not commit ensuring committed transactions
are strictly serializable. This allows us to defer consistency
checks until commit time instead of re-checking consistency
on each object read. However, it adds some programming
complexity: FaRM applications must handle these tempo-
rary inconsistencies during execution [20]. It is possible to
deal with these inconsistencies automatically [12].
The FaRM API also provides lock-free reads, which are
optimized single-object read only transactions, and locality
hints, which enable programmers to co-locate related objects
on the same set of machines. These can be used by applica-
tions to improve performance as described in [16].
Figure 3 shows a FaRM instance with four machines. The
ﬁgure also shows the internal components of machine A.
Each machine runs FaRM in a user process with a kernel
thread pinned to each hardware thread. Each kernel thread
runs an event loop that executes application code and polls
the RDMA completion queues.
A FaRM instance moves through a sequence of conﬁg-
urations over time as machines fail or new machines are
added. A conﬁguration is a tuple ⟨i, S, F, CM⟩where i is a
unique, monotonically increasing 64-bit conﬁguration iden-
tiﬁer, S is the set of machines in the conﬁguration, F is a
mapping from machines to failure domains that are expected
to fail independently (e.g., different racks), and CM ∈S
is the conﬁguration manager. FaRM uses a Zookeeper [21]
coordination service to ensure machines agree on the cur-
rent conﬁguration and to store it, as in Vertical Paxos [25].
But it does not rely on Zookeeper to manage leases, detect
failures, or coordinate recovery, as is usually done. The CM
does these using an efﬁcient implementation that leverages
RDMA to recover fast. Zookeeper is invoked by the CM
once per conﬁguration change to update the conﬁguration.
56

--- PDF page 4 ---
The global address space in FaRM consists of 2 GB re-
gions, each replicated on one primary and f backups, where
f is the desired fault tolerance. Each machine stores sev-
eral regions in non-volatile DRAM that can be read by other
machines using RDMA. Objects are always read from the
primary copy of the containing region, using local mem-
ory accesses if the region is on the local machine and using
one-sided RDMA reads if remote. Each object has a 64-bit
version that is used for concurrency control and replication.
The mapping of a region identiﬁer to its primary and back-
ups is maintained by the CM and replicated with the region.
These mappings are fetched on demand by other machines
and cached by threads together with the RDMA references
needed to issue one-sided RDMA reads to the primary.
Machines contact the CM to allocate a new region. The
CM assigns a region identiﬁer from a monotonically increas-
ing counter and selects replicas for the region. Replica selec-
tion balances the number of regions stored on each machine
subject to the constraints that there is enough capacity, each
replica is in a different failure domain, and the region is co-
located with a target region when the application speciﬁes
a locality constraint. It then sends a prepare message to the
selected replicas with the region identiﬁer. If all replicas re-
port success in allocating the region, the CM sends a com-
mit message to all of them. This two-phase protocol ensures
a mapping is valid and replicated at all the region replicas
before it is used.
This centralized approach provides more ﬂexibility to
satisfy failure independence and locality constraints than
our previous approach based on consistent hashing [16]. It
also makes it easier to balance load across machines and to
operate close to capacity. With 2 GB regions, we expect up to
250 regions on a typical machine and hence that a single CM
could handle region allocation for thousands of machines.
Each machine also stores ring buffers that implement
FIFO queues [16]. They are used either as transaction logs
or message queues. Each sender-receiver pair has its own
log and message queue, which are physically located on the
receiver. The sender appends records to the log using one-
sided RDMA writes to its tail. These writes are acknowl-
edged by the NIC without involving the receiver’s CPU. The
receiver periodically polls the head of the log to process
records. It lazily updates the sender when it truncates the
log, allowing the sender to reuse space in the ring buffer.
4.
Distributed transactions and replication
FaRM integrates the transaction and replication protocols
to improve performance. It uses fewer messages than tradi-
tional protocols, and exploits one-sided RDMA reads and
writes for CPU efﬁciency and low latency. FaRM uses
primary-backup replication in non-volatile DRAM for both
data and transaction logs, and uses unreplicated transaction
coordinators that communicate directly with primaries and
backups. It uses optimistic concurrency control with read
Serialization 
point
C
P1
P2
B1
B2
Execute phase
P3
B3
Report committed to app
Commit phase
1. LOCK
2. VALIDATE
3. COMMIT
BACKUP
4. COMMIT
PRIMARY
Decision
5. TRUNCATE
Figure 4. FaRM commit protocol with a coordinator C,
primaries on P1, P2, P3, and backups on B1, B2, B3. P1 and
P2 are read and written. P3 is only read. We use dashed lines
for RDMA reads, solid ones for RDMA writes, dotted ones
for hardware acks, and rectangles for object data.
validation, as in some software transactional memory sys-
tems (e.g., TL2 [15]).
Figure 4 shows the timeline for a FaRM transaction and
tables 1 and 2 list all log record and message types used in
the transaction protocol. During the execution phase, trans-
actions use one-sided RDMA to read objects and they buffer
writes locally. The coordinator also records the addresses
and versions of all objects accessed. For primaries and back-
ups on the same machine as the coordinator, object reads
and writes to the log use local memory accesses rather than
RDMA. At the end of the execution, FaRM attempts to com-
mit the transaction by executing the following steps:
1. Lock. The coordinator writes a LOCK record to the log
on each machine that is a primary for any written object. This
contains the versions and new values of all written objects on
that primary, as well as the list of all regions with written
objects. Primaries process these records by attempting to
lock the objects at the speciﬁed versions using compare-
and-swap, and send back a message reporting whether all
locks were successfully taken. Locking can fail if any object
version changed since it was read by the transaction, or if
the object is currently locked by another transaction. In this
case, the coordinator aborts the transaction. It writes an abort
record to all primaries and returns an error to the application.
2. Validate. The coordinator performs read validation by
reading, from their primaries, the versions of all objects
that were read but not written by the transaction. If any
object has changed, validation fails and the transaction is
aborted. Validation uses one-sided RDMA reads by default.
For primaries that hold more than tr objects, validation is
done over RPC. The threshold tr (currently 4) reﬂects the
CPU cost of an RPC relative to an RDMA read.
3. Commit backups. The coordinator writes a COMMIT-
BACKUP record to the non-volatile logs at each backup and
then waits for an ack from the NIC hardware without inter-
57

--- PDF page 5 ---
Log record type
Contents
LOCK
transaction ID, IDs of all regions with objects written by the transaction, and addresses, versions, and values of
all objects written by the transaction that the destination is primary for
COMMIT-BACKUP
contents are the same as lock record
COMMIT-PRIMARY
transaction ID to commit
ABORT
transaction ID to abort
TRUNCATE
low bound transaction ID for non-truncated transactions and transaction IDs to truncate
Table 1. Log record types used in the transaction protocol. The low bound on transaction identiﬁers that have not been
truncated and a transaction identiﬁer for truncation are piggybacked on each record.
Message type
Contents
LOCK-REPLY
transaction ID, result indicating whether locking succeeded
VALIDATE
addresses and versions of objects read from destination (not sent when validation is done over RDMA reads)
NEED-RECOVERY
conﬁguration ID, region ID, and transaction IDs to be recovered (sent by backup to primary)
FETCH-TX-STATE
conﬁguration ID, region ID, and transaction IDs whose state is requested (sent by primary to backup)
SEND-TX-STATE
conﬁguration ID, region ID, transaction ID, and contents of lock record for transaction requested by fetch
REPLICATE-TX-STATE
conﬁguration ID, region ID, transaction ID, and contents of lock record (sent by primary to backup)
RECOVERY-VOTE
conﬁguration ID, region ID, transaction ID, region IDs for regions modiﬁed by the transaction, and vote
REQUEST-VOTE
conﬁguration ID, transaction ID, and region ID
COMMIT-RECOVERY
conﬁguration ID, and transaction ID
ABORT-RECOVERY
conﬁguration ID, and transaction ID
TRUNCATE-RECOVERY
conﬁguration ID, and transaction ID
Table 2. Message types used in the transaction protocol. All but the ﬁrst two are used only during recovery.
rupting the backup’s CPU. The COMMIT-BACKUP log record
has the same payload as a LOCK record.
4. Commit primaries. After all COMMIT-BACKUP writes
have been acked, the coordinator writes a
COMMIT-
PRIMARY record to the logs at each primary. It reports com-
pletion to the application on receiving at least one hardware
ack for such a record, or if it wrote one locally. Primaries
process these records by updating the objects in place, incre-
menting their versions, and unlocking them, which exposes
the writes committed by the transaction.
5. Truncate. Backups and primaries keep the records in
their logs until they are truncated. The coordinator truncates
logs at primaries and backups lazily after receiving acks
from all primaries. It does this by piggybacking identiﬁers
of truncated transactions in other log records. Backups apply
the updates to their copies of the objects at truncation time.
Correctness.
Committed read-write transactions are seri-
alizable at the point where all the write locks were acquired,
and committed read-only transactions at the point of their
last read. This is because the versions of all read and written
objects at the serialization point are the same as the versions
seen during execution. Locking ensures this for objects that
were written and validation ensures this for objects that were
only read. In the absence of failures this is equivalent to ex-
ecuting and committing the entire transaction atomically at
the serialization point. Serializability in FaRM is also strict:
the serialization point is always between the start of execu-
tion and the completion being reported to the application.
To ensure serializability across failures, it is necessary
to wait for hardware acks from all backups before writing
COMMIT-PRIMARY. Assume that the coordinator does not
receive an ack from some backup b for a region r. Then
a primary could expose transaction modiﬁcations and later
fail together with the coordinator and the other replicas of r
without b ever receiving the COMMIT-BACKUP record. This
would result in losing the updates to r.
Since the read set is stored only at the coordinator, a
transaction is aborted if the coordinator fails and no com-
mit record survives to attest to the success of validation. So
it is necessary for the coordinator to wait for a successful
commit at one of the primaries before reporting a success-
ful commit to the application. This ensures that at least one
commit record survives any f failures for transactions re-
ported committed to the application. Otherwise, such a trans-
action could still abort if the coordinator and all the backups
failed before any COMMIT-PRIMARY record was written, be-
cause only LOCK records would survive and there would be
no record that validation had succeeded.
In traditional two-phase commit protocols, participants
can reserve resources to commit the transaction when they
process the prepare message, or refuse to prepare the trans-
action if they do not have enough resources. However, as
our protocol avoids involving the backups’ CPUs during the
commit, the coordinator must reserve log space at all par-
ticipants to guarantee progress. Coordinators reserve space
for all commit protocol records including truncate records in
primary and backup logs before starting the commit proto-
col. Log reservations are a local operation at the coordinator
58

--- PDF page 6 ---
because the coordinator writes records to the log it owns at
each participant. The reservation is released when the corre-
sponding record is written. Truncation record reservations
are also released if the truncation is piggybacked on an-
other message. If the log becomes full, the coordinator uses
the reservations to write explicit truncate records to free up
space in the log. This is rare but needed to ensure liveness.
Performance.
For our target hardware, this protocol has
several advantages over traditional distributed commit proto-
cols. Consider a two-phase commit protocol with replication
such as Spanner’s [11]. Spanner uses Paxos [24] to replicate
the transaction coordinator and its participants, which are the
machines that store data read or written by the transaction.
Each Paxos state machine takes the role of an individual ma-
chine in a traditional two-phase commit protocol [19]. This
requires 2f +1 replicas to tolerate f failures and, since each
state machine operation requires at least 2f + 1 round trip
messages, it requires 4P(2f + 1) messages (where P is the
number of participants in the transaction).
FaRM uses primary-backup replication instead of Paxos
state machine replication. This reduces the number of copies
of data to f + 1, and also reduces the number of messages
transmitted during a transaction. Coordinator state is not
replicated and coordinators communicate directly with pri-
maries and backups, further reducing latency and message
counts. FaRM’s overhead due to replication is minimal: a
single RDMA write to each remote machine having a backup
of any written object. Backups of read-only participants are
not involved in the protocol at all. Additionally, read valida-
tion over RDMA ensures that primaries of read-only partici-
pants do no CPU work, and using one-way RDMA writes for
COMMIT-PRIMARY and COMMIT-BACKUP records reduces
waiting for remote CPUs and also allows the remote CPU
work to be lazy and batched.
The FaRM commit phase uses Pw(f + 3) one-sided
RDMA writes where Pw is the number of machines that are
primaries for objects written by the transaction, and Pr one-
sided RDMA reads where Pr is the number of objects read
from remote primaries but not written. Read validation adds
two one-sided RDMA latencies to the critical path but this is
a good trade-off: the added latency is only a few microsec-
onds without load and the reduction in CPU overhead results
in higher throughput and lower latency under load.
5.
Failure recovery
FaRM provides durability and high availability using repli-
cation. We assume that machines can fail by crashing but can
recover without losing the contents of non-volatile DRAM.
We rely on bounded clock drift for safety and on eventually
bounded message delays for liveness.
We provide durability for all committed transactions even
if the entire cluster fails or loses power: all committed state
can be recovered from regions and logs stored in non-volatile
DRAM. We ensure durability even if at most f replicas per
object lose the contents of non-volatile DRAM. FaRM can
also maintain availability with failures and network parti-
tions provided a partition exists that contains a majority of
the machines which remain connected to each other and to a
majority of replicas in the Zookeeper service, and the parti-
tion contains at least one replica of each object.
Failure recovery in FaRM has ﬁve phases described be-
low: failure detection, reconﬁguration, transaction state re-
covery, bulk data recovery, and allocator state recovery.
5.1
Failure detection
FaRM uses leases [18] to detect failures. Every machine
(other than the CM) holds a lease at the CM and the CM
holds a lease at every other machine. Expiry of any lease
triggers failure recovery. Leases are granted using a 3-way
handshake. Each machine sends a lease request to the CM
and it responds with a message that acts as both a lease grant
to the machine and a lease request from the CM. Then, the
machine replies with a lease grant to the CM.
FaRM leases are extremely short, which is key to high
availability. Under heavy load, FaRM can use 5 ms leases for
a 90-machine cluster with no false positives. Signiﬁcantly
larger clusters may require a two-level hierarchy, which in
the worst case would double failure detection time.
Achieving short leases under load required careful imple-
mentation. FaRM uses dedicated queue pairs for leases to
avoid having lease messages delayed in a shared queue be-
hind other message types. Using a reliable transport would
require an additional queue pair at the CM for each ma-
chine. This would result in poor performance due to capac-
ity misses in the NIC’s queue pair cache [16]. Instead the
lease manager uses Inﬁniband send and receive verbs with
the connectionless unreliable datagram transport, which re-
quires space for only one additional queue pair on the NIC.
By default, lease renewal is attempted every 1/5 of the lease
expiry period to account for potential message loss.
Lease renewal must also be scheduled on the CPU in a
timely way. FaRM uses a dedicated lease manager thread
that runs at the highest user-space priority (31 on Windows).
The lease manager thread is not pinned to any hardware
thread and it uses interrupts instead of polling to avoid starv-
ing critical OS tasks that must run periodically on every
hardware thread. This increases message latency by a few
microseconds, which is not problematic for leases.
In addition, we do not assign FaRM threads to two hard-
ware threads on each machine, leaving them for the lease
manager. Our measurements show that the lease manager
usually runs on these hardware threads without impacting
other FaRM threads, but sometimes it is preempted by higher
priority tasks that cause it to run on other hardware threads.
So pinning the lease manager to a hardware thread would
likely result in false positives when using short leases.
Finally, we preallocate all memory used by the lease
manager during initialization and we page in and pin all the
code it uses to avoid delays due to memory management.
59

--- PDF page 7 ---
CM=S1
S2
S3
suspect S3
S4
1. SUSPECT
Zookeeper
stop RDMA reads to S3
Update <9, …> to 
<10, {S1,S2,S4}, F, CM=S1>
2. PROBE
3. UPDATE 
CONFIGURATION
5. SEND NEW 
CONFIGURATION
4. REMAP 
REGIONS
6. APPLY NEW 
CONFIGURATION
7. COMMIT NEW 
CONFIGURATION
REMAP 
Figure 5. Reconﬁguration
5.2
Reconﬁguration
The reconﬁguration protocol moves a FaRM instance from
one conﬁguration to the next. Using one-sided RDMA op-
erations is important to achieve good performance but it im-
poses new requirements on the reconﬁguration protocol. For
example, a common technique to achieve consistency is to
use leases [18]: servers check if they hold a lease for an
object before replying to requests to access the object. If a
server is evicted from the conﬁguration, the system guaran-
tees that the objects it stores cannot be mutated until after its
lease expires (e.g., [7]). FaRM uses this technique when ser-
vicing requests from external clients that communicate with
the system using messages. But since machines in the FaRM
conﬁguration read objects using RDMA reads without in-
volving the remote CPU, the server’s CPU cannot check if
it holds the lease. Current NIC hardware does not support
leases and it is unclear if it will in the future.
We solve this problem by implementing precise member-
ship [10]. After a failure, all machines in a new conﬁguration
must agree on its membership before allowing object muta-
tions. This allows FaRM to perform the check at the client
rather than at the server. Machines in the conﬁguration do
not issue RDMA requests to machines that are not in it, and
replies to RDMA reads and acks for RDMA writes from ma-
chines no longer in the conﬁguration are ignored.
Figure 5 shows an example reconﬁguration timeline that
consists of the following steps:
1. Suspect. When a lease for a machine expires at the
CM, it suspects that machine of failure and initiates recon-
ﬁguration. At this point it starts blocking all external client
requests. If a non-CM machine suspects the CM of failure
due to a lease expiry, it ﬁrst asks one of a small number of
“backup CMs” to initiate reconﬁguration (the k successors
of the CM using consistent hashing). If the conﬁguration is
unchanged after a timeout period then it attempts the recon-
ﬁguration itself. This design avoids a large number of simul-
taneous reconﬁguration attempts if the CM fails. In all cases,
the machine initiating the reconﬁguration will try to become
the new CM as part of the reconﬁguration.
2. Probe. The new CM issues an RDMA read to all the
machines in the conﬁguration except the machine that is
suspected. Any machine for which the read fails is also
suspected. These read probes allow handling of correlated
failures that affect several machines, e.g., power and switch
failures, by a single reconﬁguration. The new CM proceeds
with the reconﬁguration only if it obtains responses for a
majority of the probes. This ensures that if the network is
partitioned, the CM will not be in the smaller partition.
3. Update conﬁguration. After receiving replies to the
probes, the new CM attempts to update the conﬁguration
data stored in Zookeeper to ⟨c + 1, S, F, CMid⟩, where c is
the current conﬁguration identiﬁer, S is the set of machines
that replied to the probes, F is the mapping of machines
to failure domains, and CMid is its own identiﬁer. We use
Zookeeper znode sequence numbers to implement an atomic
compare-and-swap that succeeds only if the current conﬁgu-
ration is still c. This ensures that only one machine can suc-
cessfully move the system to the conﬁguration with identiﬁer
c+1 (and become CM) even if multiple machines simultane-
ously attempt a conﬁguration change from the conﬁguration
with identiﬁer c.
4. Remap regions. The new CM then reassigns regions
previously mapped to failed machines to restore the num-
ber of replicas to f + 1. It tries to balance load and satisfy
application-speciﬁed locality hints subject to capacity and
failure independence constraints. For failed primaries, it al-
ways promotes a surviving backup to be the new primary to
reduce the time to recover. If it detects regions that lost all
their replicas or there is no space to re-replicate regions, it
signals an error.
5. Send new conﬁguration. After remapping regions, the
CM sends a NEW-CONFIG message to all the machines in
the conﬁguration with the conﬁguration identiﬁer, its own
identiﬁer, the identiﬁers of the other machines in the conﬁg-
uration, and all the new mappings of regions to machines.
NEW-CONFIG also resets the lease protocol if the CM has
changed: it acts as a lease request from the new CM to each
machine. If the CM is unchanged, lease exchange continues
during reconﬁguration to detect additional failures quickly.
6. Apply new conﬁguration. When a machine receives a
NEW-CONFIG with a conﬁguration identiﬁer that is greater
than its own, it updates its current conﬁguration identiﬁer
and its cached copy of the region mappings, and allocates
space to hold any new region replicas assigned to it. From
this point, it does not issue new requests to machines that
are not in the conﬁguration and it rejects read responses
and write acks from those machines. It also starts blocking
requests from external clients. Machines reply to the CM
with a NEW-CONFIG-ACK message. If the CM has changed,
this both grants a lease to the CM and requests a lease.
7. Commit new conﬁguration. Once the CM receives
NEW-CONFIG-ACK messages from all machines in the con-
ﬁguration, it waits to ensure that any leases granted in pre-
vious conﬁgurations to machines no longer in the conﬁg-
uration have expired. The CM then sends a NEW-CONFIG-
COMMIT to all the conﬁguration members that also acts as
60

--- PDF page 8 ---
NEW-
CONFIG
NEW-
CONFIG-
COMMIT
P
B2
B1
C
2. DRAIN
2. DRAIN
2. DRAIN
3. FIND
RECOVERING
TXs
4. 
ACQUIRE 
LOCKS
5. 
REPLICATE 
LOGS
6. 
VOTE
7. DECIDE
region is active
1. BLOCK
1. BLOCK
1. BLOCK
fetch missing
transactions
Figure 6. Transaction state recovery showing a coordinator
C, primary P, and two backups B1 and B2
a lease grant. All members now unblock previously blocked
external client requests and initiate transaction recovery.
5.3
Transaction state recovery
FaRM recovers transaction state after a conﬁguration change
using the logs distributed across the replicas of objects mod-
iﬁed by a transaction. This involves recovering the state both
at the replicas of objects modiﬁed by the transaction and at
the coordinator to decide on the outcome of the transaction.
Figure 6 shows an example transaction recovery timeline.
FaRM achieves fast recovery by distributing work across
threads and machines in the cluster. Draining (step 2) is done
for all message logs in parallel. Step 1 and steps 3–5 are done
for all regions in parallel. Steps 6–7 are done for all recover-
ing transactions in parallel.
1. Block access to recovering regions. When the primary
of a region fails, one of the backups is promoted to be
the new primary during reconﬁguration. We cannot allow
access to the region until all transactions that updated it have
been reﬂected at the new primary. We do this by blocking
requests for local pointers and RDMA references to the
region until step 4 when all write locks have been acquired
for all recovering transactions that updated the region.
2. Drain logs. One-sided RDMA writes also impact trans-
action recovery. A general approach to consistency across
conﬁgurations is to reject messages from old conﬁgurations.
FaRM cannot use this approach because NICs acknowledge
COMMIT-BACKUP and COMMIT-PRIMARY records written
to transaction logs regardless of the conﬁguration in which
they were issued. Since coordinators only wait for these acks
before exposing the updates and reporting success to the ap-
plication, machines cannot always reject records from pre-
vious conﬁgurations when they process them. We solve this
problem by draining logs to ensure that all relevant records
are processed during recovery: all machines process all the
records in their logs when they receive a NEW-CONFIG-
COMMIT message. They record the conﬁguration identiﬁer
in a variable LastDrained when they are done.
FaRM transactions have unique identiﬁers ⟨c, m, t, l⟩as-
signed at the start of commit that encode the conﬁguration
c in which the commit started, the machine identiﬁer m of
the coordinator, the thread identiﬁer t of the coordinator,
and a thread-local unique identiﬁer l. Log records for trans-
actions with conﬁguration identiﬁers less than or equal to
LastDrained are rejected.
3. Find recovering transactions. A recovering transaction
is one whose commit phase spans conﬁguration changes, and
for which some replica of a written object, some primary of
a read object, or the coordinator has changed due to recon-
ﬁguration. During log draining, the transaction identiﬁer and
list of updated region identiﬁers in each log record in each
log is examined to determine the set of recovering transac-
tions. Only recovering transactions go through transaction
recovery at primaries and backups, and coordinators reject
hardware acks only for recovering transactions.
All machines must agree on whether a given transaction
is a recovering transaction or not. We achieve this by piggy-
backing some extra metadata on the communication during
the reconﬁguration phase. The CM reads the LastDrained
variable at each machine as part of the probe read. For each
region r whose mapping has changed since LastDrained, the
CM sends two conﬁguration identiﬁers in the NEW-CONFIG
message to that machine. These are LastPrimaryChange[r],
the last conﬁguration identiﬁer when the primary of r
changed, and LastReplicaChange[r], the last conﬁguration
identiﬁer when any replica of r changed. A transaction that
started committing in conﬁguration c −1 is recovering in
conﬁguration c unless: for all regions r containing objects
modiﬁed by the transaction LastReplicaChange[r] < c, for
all regions r′ containing objects read by the transaction
LastPrimaryChange[r′] < c, and the coordinator has not
been removed from conﬁguration c.
Records for a recovering transaction may be distributed
over the logs of different primaries and backups updated
by the transaction. Each backup of a region sends a NEED-
RECOVERY message to the primary with the conﬁguration
identiﬁer, the region identiﬁer, and the identiﬁers of recover-
ing transactions that updated the region.
4. Lock recovery. The primary of each region waits un-
til the local machine logs have been drained and NEED-
RECOVERY messages have been received from each backup,
to build the complete set of recovering transactions that af-
fect the region. It then shards the transactions by identiﬁer
across its threads such that each thread t recovers the state of
transactions with coordinator thread identiﬁer t. In parallel,
the threads in the primary fetch any transaction log records
from backups that are not already stored locally and then
lock any objects modiﬁed by recovering transactions.
When lock recovery is complete for a region, the region
is active and local and remote coordinators can obtain local
pointers and RDMA references, which allows them to read
objects and commit updates to this region in parallel with
subsequent recovery steps.
5. Replicate log records. The threads in the primary repli-
cate log records by sending backups the REPLICATE-TX-
STATE message for any transactions that they are missing.
61

--- PDF page 9 ---
The message contains the region identiﬁer, the current con-
ﬁguration identiﬁer, and the same data as the LOCK record.
6. Vote. The coordinator for a recovering transaction de-
cides whether to commit or abort the transaction based on
votes from each region updated by the transaction. These
votes are sent by the primaries of each region. FaRM uses
consistent hashing to determine the coordinator for a trans-
action, ensuring that all the primaries independently agree
on the identity of the coordinator for a recovering transac-
tion. The coordinator does not change if the machine it is
running on is still in the conﬁguration, but when a coordi-
nator fails the responsibility for coordinating its recovering
transactions is spread across the machines in the cluster.
The threads in the primary send RECOVERY-VOTE mes-
sages to their peer threads in the coordinator for each re-
covering transaction that modiﬁed the region. The vote is
commit-primary if any replica saw COMMIT-PRIMARY or
COMMIT-RECOVERY. Otherwise, it votes commit-backup if
any replica saw COMMIT-BACKUP and did not see ABORT-
RECOVERY. Otherwise, it votes lock if any replica saw a
LOCK record and no ABORT-RECOVERY. Otherwise, it votes
abort. Vote messages include the conﬁguration identiﬁer, the
region identiﬁer, the transaction identiﬁer, and the list of re-
gion identiﬁers modiﬁed by the transaction.
Some primaries may not initiate voting for a transaction
because either they never received a log record for the trans-
action or they already truncated the log records for the trans-
action. The coordinator sends explicit vote requests to pri-
maries that have not already voted within a timeout period
(set to 250 µs). The REQUEST-VOTE message includes the
conﬁguration identiﬁer, the region identiﬁer, and the trans-
action identiﬁer. Primaries that do have log records for the
transaction vote as before after ﬁrst waiting for log replica-
tion for that transaction to complete.
Primaries that do not have any log records for the transac-
tion vote truncated if the transaction has already been trun-
cated and unknown if it has not. To determine if a transac-
tion has already been truncated, each thread maintains the set
of identiﬁers of transactions whose records have been trun-
cated from its logs. This set is kept compact by using a lower
bound on non-truncated transaction identiﬁers. The lower
bound is updated based on the lower bounds at each coordi-
nator, which are piggybacked on coordinator messages and
during reconﬁguration.
7. Decide. The coordinator decides to commit a trans-
action if it receives a commit-primary vote from any re-
gion. Otherwise, it waits for all regions to vote and com-
mits if at least one region voted commit-backup and all other
regions modiﬁed by the transaction voted lock, commit-
backup, or truncated. Otherwise it decides to abort. It then
sends COMMIT-RECOVERY or ABORT-RECOVERY to all par-
ticipant replicas. Both messages include the conﬁguration
identiﬁer and the transaction identiﬁer. COMMIT-RECOVERY
is processed similarly to COMMIT-PRIMARY if received at a
primary and to COMMIT-BACKUP if received at a backup.
ABORT-RECOVERY is processed similarly to ABORT. After
the coordinator receives back acks from all primaries and
backups, it sends a TRUNCATE-RECOVERY message.
Correctness.
Next we provide some intuition on how the
different steps of transaction recovery ensure strict serializ-
ability. The key idea is that recovery preserves the outcome
for transactions that were previously committed or aborted.
We say that a transaction is committed when either a primary
exposes transaction modiﬁcations, or the coordinator notiﬁes
the application that the transaction committed. A transaction
is aborted when the coordinator sends an abort message or
notiﬁes the application that the transaction has aborted. For
transactions whose outcome has not yet been decided, recov-
ery may commit or abort the transaction but it ensures that
any recovery from additional failures preserves the outcome.
The outcome of transactions that are not recovering
(step 3) is decided using the normal case protocol (Sec-
tion 4). So we will not discuss them further.
A log record for a recovering transaction that commit-
ted is guaranteed to be processed and accepted before or
during log draining (step 2). This is true because primaries
expose modiﬁcations only after processing the COMMIT-
PRIMARY record. If the coordinator notiﬁed the applica-
tion, it must have received hardware acks for all COMMIT-
BACKUP records and for at least one COMMIT-PRIMARY
record before receiving NEW-CONFIG (because it ignores
the acks after changing conﬁguration). Therefore, since the
new conﬁguration includes at least one replica for each re-
gion, at least one replica for at least one region will process
COMMIT-PRIMARY or COMMIT-BACKUP records, and at
least one replica for each other region will process COMMIT-
PRIMARY, COMMIT-BACKUP, or LOCK records.
Steps 3 and 4 ensure that the primaries for the regions
modiﬁed by the transaction see these records (unless they
have been truncated). They replicate these records to the
backups (step 5) to guarantee that voting will produce the
same results even if there are subsequent failures. Then the
primaries send votes to the coordinator based on the records
they have seen (step 6).
The decision step guarantees that the coordinator decides
to commit any transaction that has previously committed. If
any replica truncated the transaction records, all primaries
will vote commit-primary, commit-backup, or truncated. At
least one primary will send a vote other than truncated be-
cause otherwise the transaction would not be recovering. If
no replicas truncated the transaction records, at least one pri-
mary will vote commit-primary or commit-backup and the
others will vote commit-primary, commit-backup or lock.
Similarly, the coordinator will decide to abort if the trans-
action was previously aborted because in this case there will
either be no commit-primary or commit-backup records or
all replicas will have received ABORT-RECOVERY.
62

--- PDF page 10 ---
Blocking access to recovering regions (step 1) and lock
recovery (step 4) guarantee that until a recovering transac-
tion has committed or aborted, no other operation can access
objects it modiﬁed.
Performance.
FaRM uses several optimizations to achieve
fast failure recovery. Identifying recovering transactions lim-
its recovery work to only those transactions and regions that
were affected by the reconﬁguration, which could be a small
subset of the total when a single machine in a large cluster
fails. Our results indicate that this can reduce the number of
transactions to recover by an order of magnitude. The recov-
ery work itself is parallelized across regions, machines, and
threads. Making regions available immediately after lock re-
covery improves foreground performance as new transac-
tions that access these regions do not block for long. Specif-
ically, they need not wait while new replicas of these regions
are brought up to date which requires bulk movement of data
over the network.
5.4
Recovering data
FaRM must recover (re-replicate) data at new backups for
a region to ensure that it can tolerate f replica failures in
the future. Data recovery is not necessary to resume nor-
mal case operation, so we delay it until all regions become
active to minimize impact on latency-critical lock recovery.
Each machine sends a REGIONS-ACTIVE message to the CM
when all regions for which it is primary become active. After
receiving all REGIONS-ACTIVE messages, the CM sends a
message ALL-REGIONS-ACTIVE to all machines in the con-
ﬁguration. At this point, FaRM begins data recovery for new
backups in parallel with foreground operations.
A new backup for a region initially has a freshly allo-
cated and zeroed local region replica. It divides the region
across worker threads that recover it in parallel. Each thread
issues one-sided RDMA operations to read a block at a time
from the primary. We currently use 8 KB blocks, which is
large enough to use the network efﬁciently but small enough
not to impact normal case operation. To reduce impact on
foreground performance, recovery is paced by scheduling
the next read to start at a random point within an interval
after the start of the previous read (set to 4ms).
Each recovered object must be examined before being
copied to the backup. If the object has a version greater than
the local version, the backup locks the local version with
a compare-and-swap, updates the object state, and unlocks
it. Otherwise, the object has been or is being updated by a
transaction that created a version greater than or equal to the
one recovered, and the recovered state is not applied.
5.5
Recovering allocator state
The FaRM allocator splits regions into blocks (1 MB) that
are used as slabs for allocating small objects. It keeps two
pieces of meta-data: block headers, which contain the ob-
ject size, and slab free lists. Block headers are replicated
to backups when a new block is allocated. This ensures
they are available on the new primary after a failure. Since
block headers are used in data recovery, the new primary
sends them to all backups immediately after receiving NEW-
CONFIG-COMMIT. This avoids any inconsistencies when the
old primary fails while replicating the block header.
The slab free lists are kept only at the primary to reduce
the overheads of object allocation. Each object has a bit in
its header that is set by an allocation and cleared by a free
during transaction execution. This change to the object state
is replicated during transaction commit as described in Sec-
tion 4. After a failure, the free lists are recovered on the
new primary by scanning the objects in the region, which is
parallelized across all threads on the machine. To minimize
the impact on transaction lock recovery, allocation recovery
starts after ALL-REGIONS-ACTIVE is received and to mini-
mize the impact on the foreground work it is paced by scan-
ning 100 objects at a time every 100 µs. Object deallocations
are queued until a slab’s free list is recovered.
6.
Evaluation
6.1
Setup
Our experimental testbed consists of 90 machines used for
a FaRM cluster and 5 machines for a replicated Zookeeper
instance. Each machine has 256 GB of DRAM and two 8-
core Intel E5-2650 CPUs running Windows Server 2012 R2.
We enabled hyper-threading and used the ﬁrst 30 threads
for the foreground work and the remaining 2 threads for the
lease manager. Machines have two Mellanox ConnectX-3 56
Gbps Inﬁniband NICs, each used by threads on a different
socket, and are connected by a single Mellanox SX6512
switch with full bisection bandwidth. FaRM was conﬁgured
to use 3-way replication (one primary and two backups) with
a lease time of 10 ms.
6.2
Benchmarks
We use two transactional benchmarks to measure FaRM’s
performance. We implemented both benchmarks in C++
against the FaRM API. Since FaRM uses a symmetric model
to exploit locality, each machine both runs the benchmark
code and stores data. Each machine runs the benchmark code
linked with FaRM’s code on the same process. In the future,
we will compile the application from a safe language like
SQL to prevent application bugs from corrupting data.
Telecommunication Application Transaction Processing
(TATP) [32] is a benchmark for high-performance main-
memory databases. Each database table is implemented as a
FaRM hash table [16]. TATP is read dominated. 70% of the
operations are single-row lookups which use FaRM’s lock
free reads [16]. They can usually be performed with a single
RDMA read and do not require a commit phase. 10% of
the operations read 2–4 rows and require validation during
the commit phase. The remaining 20% of the operations are
updates and require the full commit protocol. Since 70% of
63

--- PDF page 11 ---
0
30
60
90
120
150
Operations / µs 
0
200
400
600
800
1000
Latency (us)
Median
99th
Figure 7. TATP performance
the updates only modify a single object ﬁeld, we function
ship these to the primary of the object as an optimization. We
used a database with 9.2 billion subscribers (except where
noted). TATP is partitionable but we have not partitioned it,
so most operations access data on remote machines.
TPC-C [38] is a well-known database benchmark with
complex transactions that access hundreds of rows. Our im-
plementation uses a schema with 16 indexes. Twelve of
these only require unordered (point) queries and updates and
are implemented as FaRM hash tables. Four of the indexes
also require range queries. These are implemented using the
FaRM B-tree. The B-Tree caches internal nodes at each ma-
chine and hence lookups require a single FaRM RDMA read
in the common case. We reserve 8 GB per machine for the
cache. We use fence keys [17, 27] to ensure traversal con-
sistency, similar to Minuet [37]. We omit a more detailed
description of the B-tree for space reasons.
We use a database with 21,600 warehouses. We co-
partition most of the hash table indexes as well as the clients
by warehouse, which means that around 10% of all trans-
actions access remote data. As speciﬁed by the benchmark,
“new order” transactions are 45% of the transaction mix. We
run the full mix but we report performance as the number of
successfully committed “new orders”.
6.3
Normal-case performance
We present the normal case (failure-free) performance of
FaRM as throughput-latency curves. For each benchmark,
we varied the load by ﬁrst increasing the number of active
threads per machine from 2 to 30 and then increasing the
concurrency per thread, until the throughput saturated. Note
that the left end of each graph still shows signiﬁcant concur-
rency and hence throughput. It does not show the minimum
latency that can be achieved by FaRM.
TATP.
Figure 7 shows that FaRM performs 140 million
TATP transactions per second with 58 µs median latency and
0
1
2
3
4
5
Operations / µs 
0
1000
2000
3000
4000
5000
6000
Latency (us)
Median
99th
Figure 8. TPC-C performance
645 µs 99th percentile latency. On the left hand side of the
graph, the median latency is only 9 µs, the 99th percentile
latency drops to 112 µs, and FaRM performs 2 million oper-
ations per second. The multi-object distributed transactions
used by TATP commit in tens of microseconds, with a mean
commit latency of 19 µs at the lowest throughput and 138 µs
at the highest.
FaRM outperforms published TATP results for Heka-
ton [14, 26], a single-machine in-memory transactional en-
gine, by a factor of 33. The Hekaton results were obtained
using different hardware but we expect a factor of 20 im-
provement when running Hekaton on one of our testbed ma-
chines. In a smaller-scale experiment, FaRM outperformed
Hekaton with just three machines. In addition, FaRM sup-
ports much larger data sets because it scales out and it pro-
vides high availability unlike single machine systems.
TPC-C.
We ran TPC-C for 60 s and we report latency and
average throughput over that period in Figure 8. FaRM per-
forms up to 4.5 million TPC-C “new order” transactions per
second with median latency of 808 µs and 99th percentile
latency of 1.9 ms. The latency can be halved with a small
10% impact in throughput. The best published TPC-C per-
formance we know of is from Silo [39, 40] which is a single-
machine in-memory system with logging to FusionIO SSDs.
FaRM’s throughput is 17x higher than Silo without logging,
and its latency at this throughput level is 128x better than
Silo with logging.4
Read performance.
Although the focus of this paper is on
transactional performance and failure recovery, we were also
able to improve read-only performance relative to [16]. We
ran a key-value lookup-only workload with 16-byte keys and
32-byte values and a uniform access pattern. We achieved
a throughput of 790 million lookups/s with median latency
4 Silo reports total transaction counts which we multiplied by 45% to get
the “new order” count.
64

--- PDF page 12 ---
of 23 µs and 99th percentile latency of 73 µs. This improves
on previously reported per-machine throughput for the same
benchmark by 20% [16]. We do not double performance
despite doubling the number of NICs because the benchmark
becomes CPU bound.
6.4
Failures
To evaluate performance with failures, we ran the same
benchmarks and we killed the FaRM process on one of the
machines 35 s into the experiment. We show timelines with
the throughput of the 89 surviving machines aggregated at
1 ms intervals. The timelines are synchronized at experiment
start using RDMA messaging.
Figures 9 and 10 show a typical run of each benchmark on
different time scales. Both show throughput as a solid line.
The “time to full throughput” is a zoomed-in view around
the failure. It shows the time at which the failed machine’s
lease expired on the CM (“suspect”); the time at which all
read probes completed (“probe”); the time at which the CM
successfully updated Zookeeper (“zookeeper”); the time at
which the new conﬁguration was committed at all surviving
machines (“conﬁg-commit”); the time at which all regions
are active (“all-active”); and the time at which background
data recovery begins (“data-rec-start”). The “time to full
data recovery” shows a zoomed-out view that includes the
time when all data is recovered at backups (”done”). A
dashed line shows the cumulative number of backup regions
recovered over time by data recovery.
TATP.
The timelines for a typical TATP run are shown in
Figure 9. We conﬁgured it for maximum throughput: each
machine runs 30 threads with 8 concurrent transactions per
thread. Figure 9(a) shows that throughput drops sharply at
the failure but recovers rapidly. The system is back to peak
throughput in less than 40 ms. All regions become active in
39 ms. Figure 9(b) shows that data recovery, which is paced,
does not impact foreground throughput. The failed machine
hosted 84 2 GB regions. Each thread fetches 8 KB blocks
every 2 ms, which means that it takes around 17 s to recover
a 2 GB region on a single machine. Machines recover one
region at a time in parallel with each other and at roughly the
same pace, hence the number of regions recovered moves in
large steps. The recovery load (i.e., the number of regions
per-machine that had a replica on the failed machine) is
well balanced across the cluster: 64 machines recover one
region and 10 machines recover two. This explains why re-
replication of most regions completes in around 17 s and
why all regions are fully re-replicated in less than 35 s. Some
regions are not fully allocated, so their recovery takes less
time. This is why re-replication of some regions completes
in less than 17 s.
The ﬁgure also shows that TATP has some dips in
throughput even when there are no failures. We believe that
this is because of skewed access in the benchmark; the
Figure 11. TATP performance timeline with CM failure
throughput drops when many transactions conﬂict and back
off on hot keys at the same time.
TPC-C.
Figure 10 shows the timelines for TPC-C. Fig-
ure 10(a) shows that the system regains most of the through-
put in less than 50 ms and that all regions become active
shortly after that. It takes the system slightly more time to re-
cover transaction locks than with TATP because TPC-C has
more complex transactions. The main difference is that re-
covery of data takes longer (Figure 10(b)) even though TPC-
C recovers only 63 regions in the experiment. This is because
TPC-C co-partitions its hash tables to exploit locality and
improve performance, which results in reduced recovery par-
allelism because multiple regions are replicated on the same
set of machines to satisfy the locality constraints speciﬁed
by the application. In the experiment, two machines recover
17 regions each, which leads to data recovery taking over
4 minutes. Note that TPC-C throughput degrades gradually
over time in Figure 10(b) because the size of the database
increases very quickly.
Failing the CM.
Figure 11 shows TATP throughput over
time when the CM process fails. Recovery is slower than
when a non-CM process fails. It takes about 110 ms for
throughput to get back to the same level as before the failure.
The main reason for the increase in recovery time is an in-
crease in the reconﬁguration time: from 20 ms in Figure 9(a)
to 97 ms. Most of this time is spent by the new CM building
data structures that are only maintained at the CM. It should
be possible to eliminate this delay by having all the machines
maintain these data structures incrementally as they learn re-
gion mappings from the CM.
Distribution of recovery times.
We repeated the TATP re-
covery experiment (without CM failures) 40 times to obtain
a distribution of recovery times. The experiments were run
with a smaller data set (3.5 billion subscribers) to shorten
experiment times, but we conﬁrmed that the time to regain
65

--- PDF page 13 ---
(a) Time to full throughput
(b) Time to full data recovery
Figure 9. TATP performance timeline with failure
(a) Time to full throughput
(b) Time to full data recovery
Figure 10. TPC-C performance timeline with failure
throughput after a failure was the same as for the larger data
sets. This is because this time is dominated by recovering
transaction state, and the number of concurrently executing
transactions is the same for both data set sizes. Figure 12
shows the distribution of recovery times. We measured re-
covery time from the point where the failed machine is sus-
pected by the CM until throughput recovers to 80% of the
average throughput before the failure. The median recovery
time is around 50 ms and in more than 70% of the execu-
tions the recovery time is less than 100 ms. In the remaining
cases, the recovery took more than 100 ms, but always less
than 200 ms.
Correlated failures.
Some failures affect more than one
machine at the same time, e.g., power or switch failures. To
deal with such coordinated failures, FaRM allows specifying
a failure domain for each machine and the CM places each
replica of a region in a different failure domain. We group
machines in our cluster into ﬁve failure domains with 18
machines each. This corresponds to the number of ports in
each leaf module in our switch. We fail all the processes in
one of these failure domains at the same time to simulate the
failure of a top-of-rack switch.
Figure 13 shows TATP throughput over time for the
72 machines that do not fail. TATP was conﬁgured to use
around 55 regions on each machine (6.9 billion subscribers
66

--- PDF page 14 ---
30
60
90
120
150
180
Recovery (ms)
10
20
30
40
50
60
70
80
90
100
Percentile
Figure 12. Distribution of recovery times for TATP
Figure 13. TATP throughput when failing 18 out of 90
machines at the same time
across the cluster) to allow enough space to re-replicate
failed regions after the failure. FaRM regains peak through-
put less than 400 ms after the failure. We repeated the exper-
iment 20 times and this time was the median of all experi-
ments. Most of this time is spent recovering transactions. We
need to recover all in-ﬂight transactions that modiﬁed any
region with a replica in a failed machine, that read a region
with the primary in a failed machine, or that had the coordi-
nator on one of the failed machines. This results in roughly
130,000 transactions that need to be recovered, compared
to 7500 with a single failure. Re-replication of data takes 4
minutes because there are 1025 regions to re-replicate. As in
previous experiments, this does not impact throughput dur-
ing recovery because of pacing. Note that during this time
each region still has two available replicas, so there is no
need to re-replicate more aggressively.
Figure 14. TATP throughput when optimizing for re-
replication delay
Figure 15. TPC-C throughput with more aggressive data
recovery
Data recovery pacing.
FaRM paces data recovery to re-
duce its impact on throughput. This increases the time to
complete re-replication of regions at new backups. Figure 14
shows throughput over time for TATP with very aggressive
data recovery: each thread fetches four 32 KB blocks con-
currently. The system only recovers peak throughput after
the majority of regions are re-replicated 800 ms after the fail-
ure. However, data recovery completes much faster: recov-
ering 83 region replicas (166 GB) takes just 1.1 s. We use
this aggressive recovery setting only when regions lose all
but one replica. The aggressive recovery rate compares fa-
vorably with RAMCloud [33] which recovers 35 GB on 80
machines in 1.6 s.
TPC-C is less sensitive to interference from background
recovery trafﬁc than TATP because only a small fraction
of accesses are to objects on remote machines. This means
that, in settings in which application-speciﬁc tuning is pos-
sible, we could re-replicate data more aggressively without
67

--- PDF page 15 ---
1
2
3
5
10
100
1000
Lease duration (ms)
0
20000
40000
60000
80000
100000
Expiry count
RPC
UD
UD+thread
UD+thread+pri
Figure 16. False positives with different lease managers
impacting performance. Figure 15 shows TPC-C throughput
over time during recovery when threads fetch 32 KB blocks
every 2 ms. Re-replication completes in 65 s, which is four
times faster than with the default settings, without any im-
pact on throughput.
6.5
Lease times
To evaluate our lease manager optimizations (Section 5.1),
we ran an experiment where all threads in all machines
repeatedly issue RDMA reads to the CM for 10 min. We
disabled recovery and counted the number of (false posi-
tive) lease expiry events across the cluster for different lease
manager implementations and different lease durations. This
benchmark is a good stress test because it generates more
trafﬁc at the CM than any of the benchmarks we described.
Figure 16 compares four lease manager implementations.
The ﬁrst uses FaRM’s RPC (RPC). The others use unreliable
datagrams: on a shared thread (UD), on a dedicated thread
at normal priority (UD+thread), and with high-priority, in-
terrupts and no pinning (UD+thread+pri).
The results show that all the optimizations are necessary
to enable using lease times of 10 ms or less without false
positives. With shared queue pairs, even 100 ms leases ex-
pire very often. The number of false positives is reduced by
using unreliable datagrams but it is not eliminated due to
contention for the CPU. Using a dedicated thread allows us
to use 100 ms leases with no false positives, but 10 ms leases
still expire due to CPU contention from background pro-
cesses running on the FaRM machines. With the interrupt-
driven lease manager running at high priority, we can use
5 ms leases for 10 min with no false positives. With shorter
leases, we still sometimes have false positives. We are lim-
ited by the network round trip time, which was up to 1 ms
with load, and by the resolution of the system timer, which
is 0.5 ms. The limited resolution of the system timer explains
why the interrupt-driven lease manager has more false posi-
tives than the polling-based one with 1 ms leases.
We conservatively set the leases to 10 ms in all our ex-
periments and have not observed any false positives during
their execution.
7.
Related work
To our knowledge, FaRM is the ﬁrst system to simultane-
ously provide high availability, high throughput, low latency,
and strict serializability. In prior work [16], we provided an
overview of an early version of FaRM that logged to SSDs
for durability and availability but we did not describe recov-
ery from failures. This paper describes a new fast recovery
protocol and an optimized transaction and replication pro-
tocol that sends signiﬁcantly fewer messages and leverages
NVRAM to avoid logging to SSDs. The optimized protocol
sends up to 44% fewer messages than the transaction pro-
tocol described in [16] and also replaces messages by one-
sided RDMA reads during the validation phase. The work
in [16] only evaluated the performance of single-key transac-
tions in the absence of failures using the YCSB benchmark.
Here we evaluate the performance of transactions with and
without failures using the TATP and TPC-C benchmarks.
RAMCloud [33, 34] is a key-value store that stores a
single copy of data in memory and uses a distributed log
for durability. It does not support multi-object transactions.
On a failure, it recovers in parallel on multiple machines, and
during this period, which can take seconds, the data on failed
machines is unavailable. FaRM supports transactions, makes
data available within tens of milliseconds of a failure, and
has an order of magnitude higher throughput per machine.
Spanner [11] was discussed in Section 4. It provides
strict serializability but is not optimized for performance
over RDMA. It uses 2f + 1 replicas compared to FaRM’s
f + 1, and sends more messages to commit than FaRM.
Sinfonia [8] offers a shared address space with serializable
transactions implemented using 2-phase commit and piggy-
backing reads into the 2-phase commit in specialized cases.
FaRM offers general distributed transactions optimized to
take advantage of RDMA.
HERD [23] is an in-memory RDMA-based key-value
store that delivers high performance per server in an asym-
metric setting where clients run on different machines from
servers. It uses RDMA writes and send/receive verbs for
messaging but does not use RDMA reads. The authors
of [23] show that one-sided RDMA reads perform worse
than a specialized RPC implementation without reliability
in an asymmetric setting. Our results use reliable communi-
cation in a symmetric setting where every machine is both a
client and a server. This allows us to exploit locality, which
is important because accessing local DRAM is signiﬁcantly
faster than using RDMA to access remote DRAM [16]. Pi-
laf [31] is a key-value store that uses RDMA reads. Nei-
ther Pilaf nor HERD support transactions. HERD is not fault
tolerant whereas Pilaf gets durability but not availability by
logging to a local disk.
68

--- PDF page 16 ---
Silo [39, 40] is a single-machine main-memory database
that achieves durability by logging to persistent storage.
It writes committed transactions to storage in batches to
achieve high throughput. Failure recovery involves reading
checkpoints and log records from storage. The storage in
Silo is local and thus availability is lost when the machine
fails. In contrast, FaRM is distributed and uses replication
in NVRAM for durability and high availability. FaRM can
regain peak throughput after a failure more than two orders
of magnitude faster than Silo for a much larger database.
By scaling out and using replication in NVRAM, FaRM
also achieves higher throughput and lower latency than Silo.
Hekaton [14, 26] is also a single-machine main-memory
database without support for scale-out or distributed trans-
actions. FaRM with 3 machines matches Hekaton’s perfor-
mance and with 90 machines has 33x the throughput.
8.
Conclusion
Transactions make it easier to program distributed systems
but many systems avoid them or weaken their consistency to
improve availability and performance. FaRM is a distributed
main memory computing platform for modern data cen-
ters that provides strictly serializable transactions with high
throughput, low latency, and high availability. Key to achiev-
ing this are new transaction, replication, and recovery pro-
tocols designed from ﬁrst principles to leverage commod-
ity networks with RDMA and a new, inexpensive approach
to providing non-volatile DRAM. The experimental results
show that FaRM provides signiﬁcantly higher throughput
and lower latency than state of the art in-memory databases.
FaRM can also recover from a machine failure back to pro-
viding peak throughput in less than 50 ms, making failures
transparent to applications.
Acknowledgments
We would like to thank Jason Nieh, our shepherd, and the
anonymous reviewers for their comments. We would also
like to thank Richard Black for his help in performance
debugging, Andy Slowey and Oleg Losinets for keeping
the test cluster running, and Chiranjeeb Buragohain, Sam
Chandrashekar, Arlie Davis, Orion Hodson, Flavio Jun-
queira, Richie Khanna, James Lingard, Samantha L¨uber,
Knut Magne Risvik, Tim Tan, Ming Wu, Ming-Chuan Wu,
Fan Yang, and Lidong Zhou for innumerous discussions and
for letting us use the whole cluster for extended periods of
time to run the ﬁnal experiments.
References
[1] Memcached. http://memcached.org.
[2] Viking
Technology.
http://www.
vikingtechnology.com/.
[3] Apache Cassandra.
http://cassandra.apache.
org/, 2015.
[4] MySQL. http://www.mysql.com/, 2015.
[5] neo4j. http://neo4j.com/, 2015.
[6] redis. http://redis.io/, 2015.
[7] ADYA, A., DUNAGAN, J., AND WOLMAN, A. Centrifuge:
Integrated lease management and partitioning for cloud ser-
vices.
In Proceedings of the 7th USENIX Symposium
on Networked Systems Design and Implementation (2010),
NSDI’10.
[8] AGUILERA, M. K., MERCHANT, A., SHAH, M., VEITCH,
A., AND KARAMANOLIS, C. Sinfonia: A new paradigm for
building scalable distributed systems. In Proceedings of 21st
ACM SIGOPS Symposium on Operating Systems Principles
(2007), SOSP’07.
[9] CHANG, F., DEAN, J., GHEMAWAT, S., HSIEH, W. C.,
WALLACH, D. A., BURROWS, M., CHANDRA, T., FIKES,
A., AND GRUBER, R. E. Bigtable: A distributed storage sys-
tem for structured data. In Proceedings of the 6th USENIX
Symposium on Operating Systems Design and Implementation
(2006), OSDI’06.
[10] CHOCKLER, G. V., KEIDAR, I., AND VITENBERG, R. Group
communication speciﬁcations: a comprehensive study. ACM
Computing Surveys (CSUR) 33, 4 (2001).
[11] CORBETT, J. C., DEAN, J., EPSTEIN, M., FIKES, A.,
FROST, C., FURMAN, J. J., GHEMAWAT, S., GUBAREV, A.,
HEISER, C., HOCHSCHILD, P., HSIEH, W. C., KANTHAK,
S., KOGAN, E., LI, H., LLOYD, A., MELNIK, S., MWAURA,
D., NAGLE, D., QUINLAN, S., RAO, R., ROLIG, L., SAITO,
Y., SZYMANIAK, M., TAYLOR, C., WANG, R., AND WOOD-
FORD, D. Spanner: Google’s globally-distributed database.
In Proceedings of the 10th USENIX Symposium on Operating
Systems Design and Implementation (2012), OSDI’12.
[12] DALESSANDRO, L., AND SCOTT, M. L. Sandboxing transac-
tional memory. In Proceedings of the 21st ACM International
Conference on Parallel Architectures and Compilation Tech-
niques (2012), PACT’12.
[13] DECANDIA, G., HASTORUN, D., JAMPANI, M., KAKULA-
PATI, G., LAKSHMAN, A., PILCHIN, A., SIVASUBRAMA-
NIAN, S., VOSSHALL, P., AND VOGELS, W. Dynamo: Ama-
zon’s highly available key-value store. In Proceedings of the
the 21st ACM Symposium on Operating Systems Principles
(2007), SOSP’07.
[14] DIACONU, C., FREEDMAN, C., ISMERT, E., LARSON, P.-
˚A., MITTAL, P., STONECIPHER, R., VERMA, N., AND
ZWILLING, M. Hekaton: SQL Server’s memory-optimized
OLTP engine. In Proceedings of the ACM SIGMOD Inter-
national Conference on Management of Data (2013), SIG-
MOD’13.
[15] DICE, D., SHALEV, O., AND SHAVIT, N. Transactional lock-
ing II. In Proceedings of the 20th International Symposium on
Distributed Computing (2006), DISC’06.
[16] DRAGOJEVI´C, A., NARAYANAN, D., HODSON, O., AND
CASTRO, M. FaRM: Fast remote memory. In Proceedings of
the 11th USENIX Conference on Networked Systems Design
and Implementation (2014), NSDI’14.
[17] GRAEFE, G.
Write-optimized B-trees.
In Proceedings of
the 30th International Conference on Very Large Data Bases
(2004), VLDB’04.
69

--- PDF page 17 ---
[18] GRAY, C., AND CHERITON, D. Leases: An efﬁcient fault-
tolerant mechanism for distributed ﬁle cache consistency.
SIGOPS Operating Systems Review (OSR) 23, 5 (1989).
[19] GRAY, J., AND REUTER, A. Transaction Processing: Con-
cepts and Techniques. 1992.
[20] GUERRAOUI, R., AND KAPALKA, M.
On the correctness
of transactional memory. In Proceedings of the 13th ACM
SIGPLAN Symposium on Principles and Practice of Parallel
Programming (2008), PPoPP’08.
[21] HUNT, P., KONAR, M., JUNQUEIRA, F. P., AND REED, B.
Zookeeper: wait-free coordination for internet-scale systems.
In Proceedings of the 2010 USENIX Annual Technical Con-
ference (2010), USENIX ATC’10.
[22] INFINIBAND TRADE ASSOCIATION. Supplement to Inﬁni-
Band Architecture Speciﬁcation Volume 1 Release 1.2.2 An-
nex A16: RDMA over Converged Ethernet (RoCE), 2010.
[23] KALIA, A., KAMINSKY, M., AND ANDERSEN, D. G. Using
RDMA efﬁciently for key-value services. In Proceedings of
the 2014 Conference on Applications, Technologies, Architec-
tures, and Protocols for Computer Communications (2014),
SIGCOMM’14.
[24] LAMPORT, L. The part-time parliament. ACM Transactions
on Computer Systems 16, 2.
[25] LAMPORT, L., MALKHI, D., AND ZHOU, L. Vertical Paxos
and primary-backup replication. In Proceedings of the 28th
ACM Symposium on Principles of Distributed Computing
(2009), PODC’09.
[26] LARSON, P.- ˚A., BLANAS, S., DIACONU, C., FREEDMAN,
C., PATEL, J. M., AND ZWILLING, M. High-performance
concurrency control mechanisms for main-memory databases.
PVLDB 5, 4 (2011).
[27] LEHMAN, P. L., AND YAO, S. B. Efﬁcient locking for con-
current operations on B-trees. ACM Transactions on Database
Systems 6, 4 (Dec. 1981).
[28] MICROSOFT.
Scaling
out
SQL
Server.
http:
//www.microsoft.com/en-us/server-
cloud/solutions/high-availability.aspx.
[29] MICROSOFT.
Open CloudServer OCS V2 speciﬁcation:
Blade, 2014.
[30] MICROSOFT.
OCS
Open
CloudServer
power
sup-
ply v2.0.
http://www.opencompute.org/wiki/
Server/SpecsAndDesigns, 2015.
[31] MITCHELL, C., YIFENG, G., AND JINYANG, L. Using one-
sided RDMA reads to build a fast, CPU-efﬁcient key-value
store. In Proceedings of the 2013 USENIX Annual Technical
Conference (2013), USENIX ATC’13.
[32] NEUVONEN,
S.,
WOLSKI,
A.,
MANNER,
M.,
AND
RAATIKKA, V.
Telecom Application Transaction Pro-
cessing
benchmark.
http://tatpbenchmark.
sourceforge.net/.
[33] ONGARO, D., RUMBLE, S. M., STUTSMAN, R., OUSTER-
HOUT, J., AND ROSENBLUM, M.
Fast crash recovery in
RAMCloud. In Proceedings of the 23rd ACM Symposium on
Operating Systems Principles (2011), SOSP’11.
[34] RUMBLE, S. M., KEJRIWAL, A., AND OUSTERHOUT, J.
Log-structured Memory for DRAM-based Storage. In Pro-
ceedings of the 12th USENIX Conference on File and Storage
Technologies (2014), FAST’14.
[35] SETHI, R. Useless actions make a difference: Strict serializ-
ability of database updates. JACM 29, 2 (1982).
[36] SHAUN HARRIS.
Microsoft reinvents datacenter power
backup with new Open Compute project speciﬁcation.
http://blogs.msdn.com/b/windowsazure/
archive/2012/11/13/windows-azure-
benchmarks-show-top-performance-for-
big-compute.aspx, 2015.
[37] SOWELL, B., GOLAB, W. M., AND SHAH, M. A. Minuet: A
scalable distributed multiversion B-tree. PVLDB 5, 9 (2012).
[38] TRANSACTION
PROCESSING
PERFORMANCE
COUNCIL
(TPC). TPC benchmark C: Standard speciﬁcation. http:
//www.tpc.org.
[39] TU, S., ZHENG, W., KOHLER, E., LISKOV, B.,
AND
MADDEN, S. Speedy transactions in multicore in-memory
databases. In Proceedings of the 24th Symposium on Operat-
ing Systems Principles (2013), SOSP’13.
[40] ZHENG, W., TU, S., KOHLER, E., AND LISKOV, B. Fast
databases with fast durability and recovery through multicore
parallelism. In Proceedings of the 11th USENIX Symposium
on Operating Systems Design and Implementation (2014),
OSDI’14.
70

### faq: FAQ

- URL: http://nil.csail.mit.edu/6.824/2021/papers/farm-faq.txt
- Local path: official-materials/faqs/farm-faq.txt

#### Archived Content

FAQ FaRM

Q: What are some systems that currently uses FaRM?

A: Just FaRM. It's not in production use; it's a recent research
prototype. I suspect it will influence future designs, and perhaps
itself be developed into a production system.

Q: Why did Microsoft Research release this? Same goes for the research
branches of Google, Facebook, Yahoo, etc. Why do they always reveal
the design of these new systems? It's definitely better for the
advancement of tech, but it seems like (at least in the short term) it
is in their best interest to keep these designs secret.

A: These companies only publish papers about a tiny fraction of the
software they write. One reason they publish is that these systems are
partially developed by people with an academic background (i.e. who
have PhDs), who feel that part of their mission in life is to help the
world understand the new ideas they invent. They are proud of their
work and want people to appreciate it. Another reason is that such
papers may help the companies attract top talent, because the papers
show that intellectually interesting work is going on there.

Q: Does FaRM really signal the end of necessary compromises in
consistency/availability in distributed systems?

A: I suspect not. For example, if you are willing to do
non-transactional one-sided RDMA reads and writes, you can do them
about 5x as fast as FaRM can do full transactions. Perhaps few people
want that 5x more performance today, but they may someday. Along
another dimension, there's a good deal of interest in transactions for
geographically distributed data, for which FaRM doesn't seem very
relevant.

Q: This paper does not really focus on the negatives of FaRM. What are
some of the biggest limitations FaRM?

A: Here are some guesses. The data has to fit in RAM. OCC will produce
lots of aborts if transactions conflict a lot. The transaction API
(described in their NSDI 2014 paper) looks awkward to use because
replies return in callbacks. Application code has to tightly
interleave executing application transactions and polling RDMA NIC
queues and logs for messages from other computers. Application code
can see inconsistencies while executing transactions that will
eventually abort. For example, if the transaction reads a big object
at the same time that a commiting transaction is overwriting the
object. The risk is that the application may crash if it isn't
defensively written. Applications may not be able to use their own
threads very easily because FaRM pins threads to cores, and uses all
cores. Of course, FaRM is a research prototype intended to explore new
ideas. It is not a finished product intended for general use. If
people continue this line of work, we might eventually see descendants
of FaRM with fewer rough edges.

Q: What's a NIC?

A: A Network Interface Card -- the hardware that connects a computer
to the network.

Q: What is RDMA? One-sided RDMA?

A: RDMA is a special feature implemented in some modern NICs (network
interface cards). The NIC looks for special command packets that
arrive over the network, and executes the commands itself (and does
not give the packets to the CPU). The commands specify memory
operations such as write a value to an address or read from an address
and send the value back over the network. In addition, RDMA NICs allow
application code to directly talk to the NIC hardware to send the
special RDMA command packets, and to be notified when the "hardware
ACK" packet arrives indicating that the receiving NIC has executed the
command.

"One-sided" refers to a situation where application code in one
computer uses these RDMA NICs to directly read or write memory in
another computer without involving the other computer's CPU. FaRM's
"Validate" phase in Section 4 / Figure 4 uses only a one-sided read.

FaRM sometimes uses RDMA as a fast way to implement an RPC-like scheme
to talk to software running on the receiving computer. The sender uses
RDMA to write the request message to an area of memory that the
receiver's FaRM software is polling (checking periodically); the
receiver sends its reply in the same way. The FaRM "Lock" phase uses
RDMA in this way.

The benefit of RDMA is speed. A one-sided RDMA read or write takes as
little as 1/18 of a microsecond (Figure 2), while a traditional RPC
might take 10 microseconds. Even FaRM's use of RDMA for messaging is a
lot faster than traditional RPC: user-space code in the receiver
frequently polls the incoming NIC queues in order to see new messages
quickly, rather than involving interrupts and user/kernel transitions.

Q: Why is FaRM's RDMA-based RPC faster than traditional RPC?

A: Traditional RPC requires the application to make a system call to
the local kernel, which asks the local NIC to send a packet. At the
receiving computer, the NIC writes the packet to a queue in memory and
interrrupts the receving computer's kernel. The kernel copies the
packet to user space and causes the application to see it. The
receving application does the reverse to send the reply (system call
to kernel, kernel talks to NIC, NIC on the other side interrupts its
kernel, &c). This point is that a huge amount of code is executed for
each RPC, and it's not very fast.

Q: Much of FaRM's performance comes from the hardware. In what ways
does the software design contribute to performance?

A: It's true that one reason FaRM is fast is that the hardware is
fast. But the hardware has been around for many years now, yet no-one
has figured out how to put all the parts together in a way that really
exploits the hardware's potential. One reason FaRM does so well is
that they simultaneously put a lot of effort into optimizing the
network, the persistent storage, and the use of CPU; many previous
systems have optimized one but not all. A specific design point is the
way FaRM uses fast one-sided RDMA (rather than slower full RPC) for
many of the interactions.

Q: Do other systems use UPS (uninterruptable power supplies, with
batteries) to implement fast but persistent storage?

A: The idea is old; for example the Harp replicated file service used
it in the early 1990s. Many storage systems use batteries in related
ways (e.g. in RAID controllers) to avoid having to wait for disk
writes. However, the kind of battery setup that FaRM uses isn't
particularly common, so software that has to be general purpose can't
rely on it. If you configure your own hardware to have batteries, then
it would make sense to modify your Raft (or k/v server) to exploit
your batteries.

Q: Would the FaRM design still make sense without the battery-backed RAM?

A: I'm not sure FaRM would work without non-volatile RAM, because then
the one-sided log writes (e.g. COMMIT-BACKUP in Figure 4) would not
persist across power failures. You could modify FaRM so that all log
updates were written to SSD before returning, but then it would have
much lower performance. An SSD write takes about 100 microseconds,
while FaRM's one-sided RDMA writes to non-volatile RAM take only a few
microseconds.

Q: Isn't DRAM inherently volatile?

A: The authors make RAM "non-volatile" by using UPS to write out the
memory to an SSD on a power failure.  But, this is indeed not
completely non-volatile, because if the computer crashes for any other
reason than a power failure, the content of the memory of the failed
machine is lost.  This is the reason why they replicate region across
several machines and have a fast recovery protocol.

Q: A FaRM server copies RAM to SSD if the power is about to fail.
Could they use mechanical hard drives instead of SSDs?

A: They use SSDs because they are fast. They could have used hard
drives without changing the design. However, it would then have taken
longer to write the data to disk during a power outage, and that would
require bigger batteries. Maybe the money they'd save by using hard
drives would be outweighed by the increased cost of batteries.

Q: What is the distinction between primaries, backups, and
configuration managers in FaRM? Why are there three roles?

A: The data is sharded among many primary/backup sets. The point of
the backups is to store a copy of the shard's data and logs in case
the primary fails. The primary performs all reads and writes to data
in the shard, while the backups perform only the writes (in order to
keep their copy of the data identical to the primary's copy). There's
just one configuration manager. It keeps track of which primaries and
backups are alive, and keeps track of how the data is sharded among
them. At a high level this arrangement is similar to GFS, which also
sharded data among many primary/backup sets, and also had a master
that kept track of where data is stored.

Q: Would FaRM make sense at small scale?

A: I think FaRM is only interesting if you need to support a huge
number of transactions per second. If you only need a few thousand
transactions per second, you can use off-the-shelf mature technology
like MySQL. You could probably set up a considerably smaller FaRM
system than the authors' 90-machine system. But FaRM doesn't make
sense unless you are sharding and replicating data, which means you
need at least four data servers (two shards, two servers per shard)
plus a few machines for ZooKeeper (though probably you could run
ZooKeeper on the four machines). Then maybe you have a system that
costs on the order of $10,000 dollars and can execute a few million
simple transactions per second, which is pretty good.

Q: Section 3 seems to say that a single transaction's reads may see
inconsistent data. That doesn't seem like it would be serializable!

A: Farm only guarantees serializability for transactions that commit.
If a transaction sees the kind of inconsistency Section 3 is talking
about, FaRM will abort the transaction. Applications must handle
inconsistency in the sense that they should not crash, so that they
can get as far as asking to commit, so that FaRM can abort them.

Q: How does FaRM ensure that a transaction's reads are consistent?
What happens if a transaction reads an object that is being modified
by a different transaction?

A: There are two dangers here. First, for a big object, the reader may
read the first half of the object before a concurrent transaction has
written it, and the second half after the concurrent transaction has
written it, and this might cause the reading program to crash. Second,
the reading transaction can't be allowed to commit if it might not be
serializable with a concurrent writing transaction.

Based on my reading of the authors' previous NSDI 2014 paper, the
solution to the first problem is that every cache line of every object
has a version number, and single-cache-line RDMA reads and writes are
atomic. The reading transaction's FaRM library fetches all of the
object's cache lines, and then checks whether they all have the same
version number. If yes, the library gives the copy of the object to
the application; if no, the library reads it again over RDMA. The
second problem is solved by FaRM's validation scheme described in
Section 4. In the VALIDATE step, if another transaction has written an
object read by our transaction since our transaction started, our
transaction will be aborted.

Q: How does log truncation work? When can a log entry be removed?
If one entry is removed by a truncate call, are all previous entries
also removed?

A: The TC tells the primaries and backups to delete the log entries
for a transaction after the TC sees that all of them have a
COMMIT-PRIMARY or COMMIT-BACKUP in their log. In order that recovery
will know that a transaction is done despite truncation, page 62
mentions that primaries remember completed transaction IDs even after
truncation. Truncation implies that all log entries before the
truncation point are deleted; this works because each primary/backup
has a separate log per TC.

Q: Is it possible for an abort to occur during COMMIT-BACKUP, perhaps
due to hardware failure?

A: I believe so. If one of the backups doesn't respond, and the TC
crashes, then there's a possibility that the transaction might be
aborted during recovery.

Q: Since this is an optimistic protocol, does it suffer when many
transactions need to modify the same object?

A: When multiple transactions modify the same object at the same time,
some of them will see during Figure 4's LOCK phase that the lock is
already held. Each such transaction will abort (they do not wait until
the lock is released), and will restart from the beginning. If that
happens a lot, performance will indeed suffer. But, for the
applications the authors measure, FaRM gets fantastic performance.
Very likely one reason is that their applications have relatively few
conflicting transactions, and thus not many aborts.

Q: Figure 7 shows significant increase in latency when the number of
operations exceeds 120 per microsecond. Why is that?

A: I suspect the limit is that the servers can only process about 140
million operations per second in total. If clients send operations
faster than that, some of them will have to wait; this waiting causes
increased latency.

Q: What is vertical Paxos?

A: It is a style of Paxos protocols where an external master performs
reconfiguration while the Paxos group can continue performing
operations while reconfiguration is in progress (see
https://lamport.azurewebsites.net/pubs/vertical-paxos.pdf for the
details).  In the FaRM paper, the authors use the term "vertical
Paxos" loosely to mean that the configuration management is done by an
external service (Zookeeper and CM) and processing writes of a
transaction is done with standard primary/backup protocol.

### homework: Question

- URL: http://nil.csail.mit.edu/6.824/2021/questions.html?q=q-farm&lec=15
- Local path: official-materials/questions/15-q-farm.html

#### Assigned Question

No compromises: distributed transactions with consistency, availability, and performance : Suppose there are two FaRM transactions that both increment the same object. They start at the same time and see the same initial value for the object. One transaction completely finishes committing (see Section 4 and Figure 4). Then the second transaction starts to commit. There are no failures. What is the evidence that FaRM will use to realize that it must abort the second transaction? At what point in the Section 4 / Figure 4 protocol will FaRM realize that it must abort?
