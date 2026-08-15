# Reading Input: Lecture 11 - Chain Replication

> This is a generated evidence bundle, not a finished study guide.
> Keep assigned reading ranges and source boundaries when summarizing.

## Video Sessions

- Part 11: Lecture 11 - Chain Replication (https://www.bilibili.com/video/BV16f4y1z7kn/?p=11)

## Resources

### paper: CR (2004)

- URL: http://nil.csail.mit.edu/6.824/2021/papers/cr-osdi04.pdf
- Local path: official-materials/papers/cr-osdi04.pdf

#### Archived Content


--- PDF page 1 ---
Chain Replication for Supporting
High Throughput and Availability
Robbert van Renesse
rvr@cs.cornell.edu
Fred B. Schneider
fbs@cs.cornell.edu
FAST Search & Transfer ASA
Tromsø, Norway
and
Department of Computer Science
Cornell University
Ithaca, New York 14853
Abstract
Chain replication is a new approach to coordinating
clusters of fail-stop storage servers. The approach is
intended for supporting large-scale storage services
that exhibit high throughput and availability with-
out sacriﬁcing strong consistency guarantees.
Be-
sides outlining the chain replication protocols them-
selves, simulation experiments explore the perfor-
mance characteristics of a prototype implementa-
tion. Throughput, availability, and several object-
placement strategies (including schemes based on
distributed hash table routing) are discussed.
1
Introduction
A storage system typically implements operations
so that clients can store, retrieve, and/or change
data. File systems and database systems are per-
haps the best known examples. With a ﬁle system,
operations (read and write) access a single ﬁle and
are idempotent; with a database system, operations
(transactions) may each access multiple objects and
are serializable.
This paper is concerned with storage systems that
sit somewhere between ﬁle systems and database
systems. In particular, we are concerned with stor-
age systems, henceforth called storage services, that
• store objects (of an unspeciﬁed nature),
• support query operations to return a value de-
rived from a single object, and
• support update operations to atomically change
the state of a single object according to some
pre-programmed,
possibly non-deterministic,
computation involving the prior state of that
object.
A ﬁle system write is thus a special case of our stor-
age service update which, in turn, is a special case
of a database transaction.
Increasingly, we see on-line vendors (like Ama-
zon.com),
search
engines
(like
Google’s
and
FAST’s), and a host of other information-intensive
services provide value by connecting large-scale stor-
age systems to networks. A storage service is the
appropriate compromise for such applications, when
a database system would be too expensive and a ﬁle
system lacks rich enough semantics.
One challenge when building a large-scale stor-
age service is maintaining high availability and
high throughput despite failures and concomitant
changes to the storage service’s conﬁguration, as
faulty components are detected and replaced.
Consistency guarantees also can be crucial. But
even when they are not, the construction of an appli-
cation that fronts a storage service is often simpli-
ﬁed given strong consistency guarantees, which as-
sert that (i) operations to query and update indi-
vidual objects are executed in some sequential order
and (ii) the eﬀects of update operations are necessar-
ily reﬂected in results returned by subsequent query
operations.
Strong consistency guarantees are often thought
to be in tension with achieving high throughput
and high availability. So system designers, reluctant
to sacriﬁce system throughput or availability, regu-
larly decline to support strong consistency guaran-
tees. The Google File System (GFS) illustrates this
thinking [11]. In fact, strong consistency guarantees

--- PDF page 2 ---
in a large-scale storage service are not incompatible
with high throughput and availability. And the new
chain replication approach to coordinating fail-stop
servers, which is the subject of this paper, simulta-
neously supports high throughput, availability, and
strong consistency.
We proceed as follows. The interface to a generic
storage service is speciﬁed in §2. In §3, we explain
how query and update operations are implemented
using chain replication.
Chain replication can be
viewed as an instance of the primary/backup ap-
proach, so §4 compares them. Then, §5 summarizes
experiments to analyze throughput and availability
using our prototype implementation of chain replica-
tion and a simulated network. Some of these simula-
tions compare chain replication with storage systems
(like CFS [7] and PAST [19]) based on distributed
hash table (DHT) routing; other simulations reveal
surprising behaviors when a system employing chain
replication recovers from server failures. Chain repli-
cation is compared in §6 to other work on scalable
storage systems, trading consistency for availability,
and replica placement. Concluding remarks appear
in §7, followed by endnotes.
2
A Storage Service Interface
Clients of a storage service issue requests for query
and update operations. While it would be possible
to ensure that each request reaching the storage ser-
vice is guaranteed to be performed, the end-to-end
argument [20] suggests there is little point in doing
so. Clients are better oﬀif the storage service sim-
ply generates a reply for each request it receives and
completes, because this allows lost requests and lost
replies to be handled as well: a client re-issues a re-
quest if too much time has elapsed without receiving
a reply.
• The reply for query(objId, opts) is derived from
the value of object objId; options opts charac-
terizes what parts of objId are returned. The
value of objId remains unchanged.
• The reply for update(objId, newVal, opts) de-
pends on options opts and, in the general case,
can be a value V produced in some nondeter-
ministic pre-programmed way involving the cur-
rent value of objId and/or value newVal; V then
becomes the new value of objId.1
Query operations are idempotent, but update op-
erations need not be. A client that re-issues a non-
idempotent update request must therefore take pre-
cautions to ensure the update has not already been
State is:
HistobjID : update request sequence
PendingobjID : request set
Transitions are:
T1: Client request r arrives:
PendingobjID := PendingobjID ∪{r}
T2: Client request r ∈PendingobjID ignored:
PendingobjID := PendingobjID −{r}
T3: Client request r ∈PendingobjID processed:
PendingobjID := PendingobjID −{r}
if r = query(objId, opts) then
reply according options opts based
on HistobjID
else if r = update(objId, newVal, opts) then
HistobjID := HistobjID · r
reply according options opts based
on HistobjID
Figure 1: Client’s View of an Object.
performed. The client might, for example, ﬁrst issue
a query to determine whether the current value of
the object already reﬂects the update.
A client request that is lost before reaching the
storage service is indistinguishable to that client
from one that is ignored by the storage service. This
means that clients would not be exposed to a new
failure mode when a storage server exhibits transient
outages during which client requests are ignored. Of
course, acceptable client performance likely would
depend on limiting the frequency and duration of
transient outages.
With chain replication, the duration of each tran-
sient outage is far shorter than the time required to
remove a faulty host or to add a new host. So, client
request processing proceeds with minimal disruption
in the face of failure, recovery, and other reconﬁg-
uration. Most other replica-management protocols
either block some operations or sacriﬁce consistency
guarantees following failures and during reconﬁgu-
rations.
We specify the functionality of our storage service
by giving the client view of an object’s state and of
that object’s state transitions in response to query
and update requests. Figure 1 uses pseudo-code to
give such a speciﬁcation for an object objID.
The ﬁgure deﬁnes the state of objID in terms
of two variables:
the sequence2 HistobjID of up-
dates that have been performed on objID and a set
PendingobjID of unprocessed requests.

--- PDF page 3 ---
replies
TAIL
queries
HEAD
updates
Figure 2: A chain.
Then, the ﬁgure lists possible state transitions.
Transition T1 asserts that an arriving client re-
quest is added to PendingobjID. That some pend-
ing requests are ignored is speciﬁed by transition
T2—this transition is presumably not taken too fre-
quently.
Transition T3 gives a high-level view of
request processing: the request r is ﬁrst removed
from PendingobjID; query then causes a suitable re-
ply to be produced whereas update also appends r
(denoted by ·) to HistobjID.3
3
Chain Replication Protocol
Servers are assumed to be fail-stop [21]:
• each server halts in response to a failure rather
than making erroneous state transitions, and
• a server’s halted state can be detected by the
environment.
With an object replicated on t servers, as many as
t−1 of the servers can fail without compromising the
object’s availability. The object’s availability is thus
increased to the probability that all servers hosting
that object have failed; simulations in §5.4 explore
this probability for typical storage systems. Hence-
forth, we assume that at most t −1 of the servers
replicating an object fail concurrently.
In chain replication, the servers replicating a given
object objID are linearly ordered to form a chain.
(See Figure 2.) The ﬁrst server in the chain is called
the head, the last server is called the tail, and request
processing is implemented by the servers roughly as
follows:
Reply Generation. The reply for every request is
generated and sent by the tail.
Query Processing. Each query request is directed
to the tail of the chain and processed there
atomically using the replica of objID stored at
the tail.
Update Processing. Each update request is di-
rected to the head of the chain. The request
is processed there atomically using replica of
objID at the head, then state changes are for-
warded along a reliable FIFO link to the next
element of the chain (where it is handled and
forwarded), and so on until the request is han-
dled by the tail.
Strong consistency thus follows because query re-
quests and update requests are all processed serially
at a single server (the tail).
Processing a query request involves only a single
server, and that means query is a relatively cheap
operation. But when an update request is processed,
computation done at t −1 of the t servers does not
contribute to producing the reply and, arguably, is
redundant. The redundant servers do increase the
fault-tolerance, though.
Note that some redundant computation associ-
ated with the t −1 servers is avoided in chain repli-
cation because the new value is computed once by
the head and then forwarded down the chain, so
each replica has only to perform a write. This for-
warding of state changes also means update can be a
non-deterministic operation—the non-deterministic
choice is made once, by the head.
3.1
Protocol Details
Clients do not directly read or write variables
HistobjID and PendingobjID of Figure 1, so we are
free to implement them in any way that is conve-
nient. When chain replication is used to implement
the speciﬁcation of Figure 1:
• HistobjID is deﬁned to be HistT
objID, the value
of HistobjID stored by tail T of the chain, and
• PendingobjID is deﬁned to be the set of client
requests received by any server in the chain and
not yet processed by the tail.
The chain replication protocols for query processing
and update processing are then shown to satisfy the
speciﬁcation of Figure 1 by demonstrating how each
state transition made by any server in the chain is
equivalent either to a no-op or to allowed transitions
T1, T2, or T3.
Given the descriptions above for how HistobjID
and Pending objID are implemented by a chain (and
assuming for the moment that failures do not occur),
we observe that the only server transitions aﬀecting
HistobjID and Pending objID are: (i) a server in the
chain receiving a request from a client (which aﬀects
PendingobjID), and (ii) the tail processing a client

--- PDF page 4 ---
request (which aﬀects HistobjID). Since other server
transitions are equivalent to no-ops, it suﬃces to
show that transitions (i) and (ii) are consistent with
T1 through T3.
Client Request Arrives at Chain. Clients send
requests to either the head (update) or the tail
(query). Receipt of a request r by either adds
r to the set of requests received by a server but
not yet processed by the tail. Thus, receipt of
r by either adds r to Pending objID (as deﬁned
above for a chain), and this is consistent with
T1.
Request Processed by Tail. Execution
causes
the request to be removed from the set of
requests received by any replica that have not
yet been processed by the tail, and therefore
it deletes the request from PendingobjID (as
deﬁned above for a chain)—the ﬁrst step of
T3. Moreover, the processing of that request
by tail T
uses replica HistT
objID
which, as
deﬁned above, implements HistobjID—and this
is exactly what the remaining steps of T3
specify.
Coping with Server Failures
In response to detecting the failure of a server that is
part of a chain (and, by the fail-stop assumption, all
such failures are detected), the chain is reconﬁgured
to eliminate the failed server. For this purpose, we
employ a service, called the master, that
• detects failures of servers,
• informs each server in the chain of its new pre-
decessor or new successor in the new chain ob-
tained by deleting the failed server,
• informs clients which server is the head and
which is the tail of the chain.
In what follows, we assume the master is a single
process that never fails. This simpliﬁes the expo-
sition but is not a realistic assumption; our pro-
totype implementation of chain replication actually
replicates a master process on multiple hosts, using
Paxos [16] to coordinate those replicas so they be-
have in aggregate like a single process that does not
fail.
The master distinguishes three cases: (i) failure
of the head, (ii) failure of the tail, and (iii) failure
of some other server in the chain.
The handling
of each, however, depends on the following insight
about how updates are propagated in a chain.
Let the server at the head of the chain be labeled
H, the next server be labeled H + 1, etc., through
the tail, which is given label T . Deﬁne
Histi
objID ⪯Histj
objID
to hold if sequence4 of requests Histi
objID at the
server with label i is a preﬁx of sequence Histj
objID
at the server with label j. Because updates are sent
between elements of a chain over reliable FIFO links,
the sequence of updates received by each server is a
preﬁx of those received by its successor. So we have:
Update Propagation Invariant. For
servers
labeled i and j such that i ≤j holds (i.e., i is
a predecessor of j in the chain) then:
Histj
objID ⪯Histi
objID.
Failure of the Head.
This case is handled by the
master removing H from the chain and making the
successor to H the new head of the chain. Such a
successor must exist if our assumption holds that at
most t −1 servers are faulty.
Changing the chain by deleting H is a transition
and, as such, must be shown to be either a no-
op or consistent with T1, T2, and/or T3 of Fig-
ure 1.
This is easily done.
Altering the set of
servers in the chain could change the contents of
PendingobjID—recall, PendingobjID is deﬁned as the
set of requests received by any server in the chain
and not yet processed by the tail, so deleting server
H from the chain has the eﬀect of removing from
PendingobjID those requests received by H but not
yet forwarded to a successor. Removing a request
from PendingobjID is consistent with transition T2,
so deleting H from the chain is consistent with the
speciﬁcation in Figure 1.
Failure of the Tail.
This case is handled by re-
moving tail T from the chain and making predeces-
sor T −of T the new tail of the chain. As before,
such a predecessor must exist given our assumption
that at most t −1 server replicas are faulty.
This change to the chain alters the values of
both PendingobjID and HistobjID, but does so in
a manner consistent with repeated T3 transitions:
PendingobjID decreases in size because HistT
objID ⪯
HistT −
objID (due to the Update Propagation Invariant,
since T −< T holds), so changing the tail from T
to T −potentially increases the set of requests com-
pleted by the tail which, by deﬁnition, decreases
the set of requests in PendingobjID. Moreover, as
required by T3, those update requests completed

--- PDF page 5 ---
by T −but not completed by T do now appear in
HistobjID because with T −now the tail, HistobjID is
deﬁned as HistT −
objID.
Failure of Other Servers.
Failure of a server S
internal to the chain is handled by deleting S from
the chain. The master ﬁrst informs S’s successor S+
of the new chain conﬁguration and then informs S’s
predecessor S−. This, however, could cause the Up-
date Propagation Invariant to be invalidated unless
some means is employed to ensure update requests
that S received before failing will still be forwarded
along the chain (since those update requests already
do appear in Histi
objID for any predecessor i of S).
The obvious candidate to perform this forwarding
is S−, but some bookkeeping and coordination are
now required.
Let U be a set of requests and let <U be a total
ordering on requests in that set. Deﬁne a request
sequence r to be consistent with (U, <U) if (i) all re-
quests in r appear in U and (ii) requests are arranged
in r in ascending order according to <U. Finally, for
request sequences r and r′ consistent with (U, <U),
deﬁne r ⊕r′ to be a sequence of all requests appear-
ing in r or in r′ such that r ⊕r′ is consistent with
(U, <U) (and therefore requests in sequence r ⊕r′
are ordered according to <U).
The Update Propagation Invariant is preserved by
requiring that the ﬁrst thing a replica S−connecting
to a new successor S+ does is: send to S+ (using
the FIFO link that connects them) those requests in
HistS−
objID that might not have reached S+; only after
those have been sent may S−process and forward
requests that it receives subsequent to assuming its
new chain position.
To this end, each server i maintains a list Senti
of update requests that i has forwarded to some
successor but that might not have been processed
by the tail. The rules for adding and deleting el-
ements on this list are straightforward: Whenever
server i forwards an update request r to its succes-
sor, server i also appends r to Senti. The tail sends
an acknowledgement ack(r) to its predecessor when
it completes the processing of update request r. And
upon receipt ack(r), a server i deletes r from Senti
and forwards ack(r) to its predecessor.
A request received by the tail must have been re-
ceived by all of its predecessors in the chain, so we
can conclude:
Inprocess Requests Invariant. If i ≤j then
Histi
objID = Histj
objID ⊕Senti.
3
master
S
1
2
4
S+
S−
Figure 3: Space-time diagram for deletion of internal
replica.
Thus, the Update Propagation Invariant will be
maintained if S−, upon receiving notiﬁcation from
the master that S+ is its new successor, ﬁrst for-
wards the sequence of requests in SentS−to S+.
Moreover, there is no need for S−to forward the
preﬁx of SentS−that already appears in HistS+
objID.
The protocol whose execution is depicted in Fig-
ure 3 embodies this approach (including the opti-
mization of not sending more of the preﬁx than nec-
essary). Message 1 informs S+ of its new role; mes-
sage 2 acknowledges and informs the master what
is the sequence number sn of the last update re-
quest S+ has received; message 3 informs S−of its
new role and of sn so S−can compute the suﬃx of
SentS−to send to S+; and message 4 carries that
suﬃx.
Extending a Chain.
Failed servers are removed
from chains. But shorter chains tolerate fewer fail-
ures, and object availability ultimately could be
compromised if ever there are too many server fail-
ures. The solution is to add new servers when chains
get short. Provided the rate at which servers fail is
not too high and adding a new server does not take
too long, then chain length can be kept close to the
desired t servers (so t −1 further failures are needed
to compromise object availability).
A new server could, in theory, be added anywhere
in a chain. In practice, adding a server T + to the
very end of a chain seems simplist. For a tail T +,
the value of SentT + is always the empty list, so ini-
tializing SentT + is trivial.
All that remains is to
initialize local object replica HistT +
objID in a way that
satisﬁes the Update Propagation Invariant.
The initialization of HistT +
objID can be accom-

--- PDF page 6 ---
plished by having the chain’s current tail T forward
the object replica HistT
objID it stores to T +.
The
forwarding (which may take some time if the ob-
ject is large) can be concurrent with T ’s processing
query requests from clients and processing updates
from its predecessor, provided each update is also
appended to SentT .
Since HistT +
objID ⪯HistT
objID
holds throughout this forwarding, Update Propaga-
tion Invariant holds. Therefore, once
HistT
objID = HistT +
objID ⊕SentT
holds, Inprocess Requests Invariant is established
and T + can begin serving as the chain’s tail:
• T is notiﬁed that it no longer is the tail.
T
is thereafter free to discard query requests it
receives from clients, but a more sensible policy
is for T to forward such requests to new tail T +.
• Requests in SentT are sent (in sequence) to T +.
• The master is notiﬁed that T + is the new tail.
• Clients are notiﬁed that query requests should
be directed to T +.
4
Primary/Backup Protocols
Chain replication is a form of primary/backup ap-
proach [3], which itself is an instance of the state ma-
chine approach [22] to replica management. In the
primary/backup approach, one server, designated
the primary
• imposes a sequencing on client requests (and
thereby ensures strong consistency holds),
• distributes
(in
sequence)
to
other
servers,
known as backups, the client requests or result-
ing updates,
• awaits acknowledgements from all non-faulty
backups, and
• after receiving those acknowledgements then
sends a reply to the client.
If the primary fails, one of the back-ups is promoted
into that role.
With chain replication, the primary’s role in se-
quencing requests is shared by two replicas.
The
head sequences update requests; the tail extends
that sequence by interleaving query requests. This
sharing of responsibility not only partitions the se-
quencing task but also enables lower-latency and
lower-overhead processing for query requests, be-
cause only a single server (the tail) is involved in
processing a query and that processing is never de-
layed by activity elsewhere in the chain. Compare
that to the primary backup approach, where the pri-
mary, before responding to a query, must await ac-
knowledgements from backups for prior updates.
In
both
chain
replication
and
in
the
pri-
mary/backup approach, update requests must be
disseminated to all servers replicating an object or
else the replicas will diverge. Chain replication does
this dissemination serially, resulting in higher la-
tency than the primary/backup approach where re-
quests were distributed to backups in parallel. With
parallel dissemination, the time needed to generate
a reply is proportional to the maximum latency of
any non-faulty backup; with serial dissemination, it
is proportional to the sum of those latencies.
Simulations reported in §5 quantify all of these
performance diﬀerences, including variants of chain
replication and the primary/backup approach in
which query requests are sent to any server (with ex-
pectations of trading increased performance for the
strong consistency guarantee).
Simulations are not necessary for understanding
the diﬀerences in how server failures are handled by
the two approaches, though.
The central concern
here is the duration of any transient outage expe-
rienced by clients when the service reconﬁgures in
response to a server failure; a second concern is the
added latency that server failures introduce.
The delay to detect a server failure is by far the
dominant cost, and this cost is identical for both
chain replication and the primary/backup approach.
What follows, then, is an analysis of the recovery
costs for each approach assuming that a server fail-
ure has been detected; message delays are presumed
to be the dominant source of protocol latency.
For chain replication, there are three cases to con-
sider: failure of the head, failure of a middle server,
and failure of the tail.
• Head Failure. Query processing continues un-
interrupted. Update processing is unavailable
for 2 message delivery delays while the master
broadcasts a message to the new head and its
successor, and then it notiﬁes all clients of the
new head using a broadcast.
• Middle Server Failure.
Query processing
continues uninterrupted.
Update processing
can be delayed but update requests are not
lost, hence no transient outage is experienced,
provided some server in a preﬁx of the chain
that has received the request remains operating.

--- PDF page 7 ---
Failure of a middle server can lead to a delay in
processing an update request—the protocol of
Figure 3 involves 4 message delivery delays.
• Tail Failure. Query and update processing are
both unavailable for 2 message delivery delays
while the master sends a message to the new
tail and then notiﬁes all clients of the new tail
using a broadcast.
With the primary/backup approach, there are two
cases to consider: failure of the primary and failure
of a backup. Query and update requests are aﬀected
the same way for each.
• Primary Failure.
A transient outage of 5
message delays is experienced, as follows. The
master detects the failure and broadcasts a mes-
sage to all backups, requesting the number of
updates each has processed and telling them
to suspend processing requests. Each backup
replies to the master. The master then broad-
casts the identity of the new primary to all
backups. The new primary is the one having
processed the largest number of updates, and
it must then forward to the backups any up-
dates that they are missing. Finally, the master
broadcasts a message notifying all clients of the
new primary.
• Backup Failure. Query processing continues
uninterrupted provided no update requests are
in progress. If an update request is in progress
then a transient outage of at most 1 message de-
lay is experienced while the master sends a mes-
sage to the primary indicating that acknowl-
edgements will not be forthcoming from the
faulty backup and requests should not subse-
quently be sent there.
So the worst case outage for chain replication
(tail failure) is never as long as the worst case out-
age for primary/backup (primary failure); and the
best case for chain replication (middle server fail-
ure) is shorter than the best case outage for pri-
mary/backup (backup failure). Still, if duration of
transient outage is the dominant consideration in
designing a storage service then choosing between
chain replication and the primary/backup approach
requires information about the mix of request types
and about the chances of various servers failing.
5
Simulation Experiments
To better understand throughput and availability
for chain replication, we performed a series of ex-
periments in a simulated network.
These involve
prototype implementations of chain replication as
well as some of the alternatives.
Because we are
mostly interested in delays intrinsic to the processing
and communications that chain replication entails,
we simulated a network with inﬁnite bandwidth but
with latencies of 1 ms per message.
5.1
Single Chain, No Failures
First, we consider the simple case when there is only
one chain, no failures, and replication factor t is 2,
3, and 10. We compare throughput for four diﬀerent
replication management alternatives:
• chain: Chain replication.
• p/b: Primary/backup.
• weak-chain:
Chain replication modiﬁed so
query requests go to any random server.
• weak-p/b: Primary/backup modiﬁed so query
requests go to any random server.
Note, weak-chain and weak-p/b do not imple-
ment the strong consistency guarantees that chain
and p/b do.
We ﬁx the query latency at a server to be 5 ms and
ﬁx the update latency to be 50 ms. (These numbers
are based on actual values for querying or updating
a web search index.) We assume each update en-
tails some initial processing involving a disk read,
and that it is cheaper to forward object-diﬀerences
for storage than to repeat the update processing
anew at each replica; we expect that the latency
for a replica to process an object-diﬀerence message
would be 20 ms (corresponding to a couple of disk
accesses and a modest computation).
So, for example, if a chain comprises three servers,
the total latency to perform an update is 94 ms: 1
ms for the message from the client to the head, 50
ms for an update latency at the head, 20 ms to pro-
cess the object diﬀerence message at each of the two
other servers, and three additional 1 ms forwarding
latencies. Query latency is only 7 ms, however.
In Figure 4 we graph total throughput as a func-
tion of the percentage of requests that are updates
for t = 2, t = 3 and t = 10. There are 25 clients,
each doing a mix of requests split between queries
and updates consistent with the given percentage.
Each client submits one request at a time, delaying
between requests only long enough to receive the
response for the previous request.
So the clients
together can have as many as 25 concurrent re-
quests outstanding.
Throughput for weak-chain

--- PDF page 8 ---
0
100
200
300
400
500
600
0
5 10 15 20 25 30 35 40 45 50
total throughput
percentage updates
weak
chain
p/b
0
100
200
300
400
500
600
0
5 10 15 20 25 30 35 40 45 50
total throughput
percentage updates
weak
chain
p/b
0
100
200
300
400
500
600
0
5 10 15 20 25 30 35 40 45 50
total throughput
percentage updates
weak
chain
p/b
(a) t = 2
(b) t = 3
(c) t = 10
Figure 4: Request throughput as a function of the percentage of updates for various replication management
alternatives chain, p/b, and weak (denoting weak-chain, and weak-p/b) and for replication factors t.
and weak-p/b was found to be virtually identical,
so Figure 4 has only a single curve—labeled weak—
rather than separate curves for weak-chain and
weak-p/b.
Observe that chain replication (chain) has equal
or superior performance to primary-backup (p/b)
for all percentages of updates and each replica-
tion factor investigated.
This is consistent with
our expectations, because the head and the tail in
chain replication share a load that, with the pri-
mary/backup approach, is handled solely by the pri-
mary.
The curves for the weak variant of chain replica-
tion are perhaps surprising, as these weak variants
are seen to perform worse than chain replication
(with its strong consistency) when there are more
than 15% update requests. Two factors are involved:
• The weak variants of chain replication and pri-
mary/backup outperform pure chain replica-
tion for query-heavy loads by distributing the
query load over all servers, an advantage that
increases with replication factor.
• Once the percentage of update requests in-
creases, ordinary chain replication outperforms
its weak variant—since all updates are done at
the head. In particular, under pure chain repli-
cation (i) queries are not delayed at the head
awaiting completion of update requests (which
are relatively time consuming) and (ii) there is
more capacity available at the head for update
request processing if query requests are not also
being handled there.
Since weak-chain and weak-p/b do not implement
strong consistency guarantees, there would seem to
be surprisingly few settings where these replication
management schemes would be preferred.
Finally, note that the throughput of both chain
replication and primary backup is not aﬀected by
replication factor provided there are suﬃcient con-
current requests so that multiple requests can be
pipelined.
5.2
Multiple Chains, No Failures
If each object is managed by a separate chain and
objects are large, then adding a new replica could
involve considerable delay because of the time re-
quired for transferring an object’s state to that new
replica.
If, on the other hand, objects are small,
then a large storage service will involve many ob-
jects. Each processor in the system is now likely to
host servers from multiple chains—the costs of mul-
tiplexing the processors and communications chan-
nels may become prohibitive. Moreover, the failure
of a single processor now aﬀects multiple chains.
A set of objects can always be grouped into a sin-
gle volume, itself something that could be considered
an object for purposes of chain replication, so a de-
signer has considerable latitude in deciding object
size.
For the next set of experiments, we assume
• a constant number of volumes,
• a hash function maps each object to a volume,
hence to a unique chain, and
• each chain comprises servers hosted by proces-
sors selected from among those implementing
the storage service.

--- PDF page 9 ---
0
20
40
60
80
100
120
0
20
40
60
80
100
120
140
average throughput
#servers
queries only
5%
10%
25%
50%
updates only
Figure 5: Average request throughput per client as
a function of the number of servers for various per-
centages of updates.
Clients are assumed to send their requests to a
dispatcher which (i) computes the hash to deter-
mine the volume, hence chain, storing the object
of concern and then (ii) forwards that request to the
corresponding chain. (The master sends conﬁgura-
tion information for each volume to the dispatcher,
avoiding the need for the master to communicate di-
rectly with clients. Interposing a dispatcher adds a
1ms delay to updates and queries, but doesn’t af-
fect throughput.) The reply produced by the chain
is sent directly to the client and not by way of the
dispatcher.
There are 25 clients in our experiments, each sub-
mitting queries and updates at random, uniformly
distributed over the chains.
The clients send re-
quests as fast as they can, subject to the restriction
that each client can have only one request outstand-
ing at a time.
To facilitate comparisons with the GFS experi-
ments [11], we assume 5000 volumes each replicated
three times, and we vary the number of servers.
We found little or no diﬀerence among chain, p/b,
weak chain, and weak p/b alternatives, so Fig-
ure 5 shows the average request throughput per
client for one—chain replication—as a function of
the number of servers, for varying percentages of
update requests.
5.3
Eﬀects of Failures on Throughput
With chain replication, each server failure causes a
three-stage process to start:
1. Some time (we conservatively assume 10 sec-
onds in our experiments) elapses before the
master detects the server failure.
2. The oﬀending server is then deleted from the
chain.
3. The master ultimately adds a new server to
that chain and initiates a data recovery process,
which takes time proportional to (i) how much
data was being stored on the faulty server and
(ii) the available network bandwidth.
Delays in detecting a failure or in deleting a faulty
server from a chain can increase request processing
latency and can increase transient outage duration.
The experiments in this section explore this.
We assume a storage service characterized by the
parameters in Table 1; these values are inspired by
what is reported for GFS [11].
The assumption
about network bandwidth is based on reserving for
data recovery at most half the bandwidth in a 100
Mbit/second network; the time to copy the 150 Gi-
gabytes stored on one server is now 6 hours and 40
minutes.
In order to measure the eﬀects of a failures on the
storage service, we apply a load. The exact details
of the load do not matter greatly. Our experiments
use eleven clients. Each client repeatedly chooses a
random object, performs an operation, and awaits
a reply; a watchdog timer causes the client to start
the next loop iteration if 3 seconds elapse and no
reply has been received. Ten of the clients exclu-
sively submit query operations; the eleventh client
exclusively submits update operations.
parameter
value
number of servers (N)
24
number of volumes
5000
chain length (t)
3
data stored per server
150 Gigabytes
maximum network band-
width devoted to data
recovery
to/from
any
server
6.25 Megabytes/sec
server reboot time after a
failure
10 minutes
Table 1: Simulated Storage Service Characteristics.

--- PDF page 10 ---
90
95
100
105
110
00:30
01:00
01:30
02:00
query thruput
time
90
95
100
105
110
00:30
01:00
01:30
02:00
query thruput
time
9
10
11
00:30
01:00
01:30
02:00
upd. thruput
time
9
10
11
00:30
01:00
01:30
02:00
upd. thruput
time
(a) one failure
(b) two failures
Figure 6: Query and update throughput with one or two failures at time 00:30.
Each experiment described executes for 2 simu-
lated hours.
Thirty minutes into the experiment,
the failure of one or two servers is simulated (as
in the GFS experiments). The master detects that
failure and deletes the failed server from all of the
chains involving that server. For each chain that was
shortened by the failure, the master then selects a
new server to add. Data recovery to those servers is
started.
Figure 6(a) shows aggregate query and update
throughputs as a function of time in the case a single
server F fails. Note the sudden drop in throughput
when the simulated failure occurs 30 minutes into
the experiment. The resolution of the x-axis is too
coarse to see that the throughput is actually zero for
about 10 seconds after the failure, since the master
requires a bit more than 10 seconds to detect the
server failure and then delete the failed server from
all chains.
With the failed server deleted from all chains, pro-
cessing now can proceed, albeit at a somewhat lower
rate because fewer servers are operational (and the
same request processing load must be shared among
them) and because data recovery is consuming re-
sources at various servers.
Lower curves on the
graph reﬂect this.
After 10 minutes, failed server
F becomes operational again, and it becomes a pos-
sible target for data recovery. Every time data re-
covery of some volume successfully completes at F,
query throughput improves (as seen on the graph).
This is because F, now the tail for another chain, is
handling a growing proportion of the query load.
One might expect that after all data recovery con-
cludes, the query throughput would be what it was
at the start of the experiment. The reality is more
subtle, because volumes are no longer uniformly dis-
tributed among the servers.
In particular, server
F will now participate in fewer chains than other
servers but will be the tail of every chain in which it
does participate. So the load is no longer well bal-
anced over the servers, and aggregate query through-
put is lower.
Update throughput decreases to 0 at the time of
the server failure and then, once the master deletes
the failed server from all chains, throughput is actu-
ally better than it was initially. This throughput im-
provement occurs because the server failure causes
some chains to be length 2 (rather than 3), reduc-
ing the amount of work involved in performing an
update.
The GFS experiments [11] consider the case where
two servers fail, too, so Figure 6(b) depicts this
for our chain replication protocol. Recovery is still
smooth, although it takes additional time.
5.4
Large Scale Replication of Criti-
cal Data
As the number of servers increases, so should the
aggregate rate of server failures. If too many servers
fail, then a volume might become unavailable. The

--- PDF page 11 ---
0.0001
0.001
0.01
0.1
1
10
100
1000
10000
1
10
100
MTBU (days)
# servers
t = 4
t = 3
t = 2
t = 1
0.0001
0.001
0.01
0.1
1
10
100
1000
10000
1
10
100
MTBU (days)
# servers
0.0001
0.001
0.01
0.1
1
10
100
1000
10000
1
10
100
# servers
t = 4
t = 3
t = 2
t = 1
0.0001
0.001
0.01
0.1
1
10
100
1000
10000
1
10
100
# servers
0.0001
0.001
0.01
0.1
1
10
100
1000
10000
1
10
100
# servers
t = 4
t = 3
t = 2
t = 1
0.0001
0.001
0.01
0.1
1
10
100
1000
10000
1
10
100
# servers
(a) ring
(b) rndseq
(c) rndpar
Figure 7: The MTBU and 99% conﬁdence intervals as a function of the number of servers and replication
factor for three diﬀerent placement strategies: (a) DHT-based placement with maximum possible parallel
recovery; (b) random placement, but with parallel recovery limited to the same degree as is possible with
DHTs; (c) random placement with maximum possible parallel recovery.
probability of this depends on how volumes are
placed on servers and, in particular, the extent to
which parallelism is possible during data recovery.
We have investigated three volume placement
strategies:
• ring: Replicas of a volume are placed at con-
secutive servers on a ring, determined by a con-
sistent hash of the volume identiﬁer.
This is
the strategy used in CFS [7] and PAST [19].
The number of parallel data recoveries possible
is limited by the chain length t.
• rndpar: Replicas of a volume are placed ran-
domly on servers. This is essentially the strat-
egy used in GFS.5 Notice that, given enough
servers, there is no limit on the number of par-
allel data recoveries possible.
• rndseq: Replicas of a volume are placed ran-
domly on servers (as in rndpar), but the max-
imum number of parallel data recoveries is lim-
ited by t (as in ring). This strategy is not used
in any system known to us but is a useful bench-
mark for quantifying the impacts of placement
and parallel recovery.
To understand the advantages of parallel data re-
covery, consider a server F that fails and was partic-
ipating in chains C1, C2, . . . , Cn. For each chain Ci,
data recovery requires a source from which the vol-
ume data is fetched and a host that will become the
new element of chain Ci. Given enough processors
and no constraints on the placement of volumes, it
is easy to ensure that the new elements are all dis-
joint. And with random placement of volumes, it is
likely that the sources will be disjoint as well. With
disjoint sources and new elements, data recovery for
chains C1, C2, . . . , Cn can occur in parallel. And a
shorter interval for data recovery of C1, C2, . . . , Cn,
implies that there is a shorter window of vulnera-
bility during which a small number of concurrent
failures would render some volume unavailable.
We seek to quantify the mean time between un-
availability (MTBU) of any object as a function of
the number of servers and the placement strategy.
Each server is assumed to exhibit exponentially dis-
tributed failures with a MTBF (Mean Time Between
Failures) of 24 hours.6 As the number of servers in
a storage system increases, so would the number of
volumes (otherwise, why add servers). In our exper-
iments, the number of volumes is deﬁned to be 100
times the initial number of servers, with each server
storing 100 volumes at time 0.
We postulate that the time it takes to copy all
the data from one server to another is four hours,
which corresponds to copying 100 Gigabytes across
a 100 Mbit/sec network restricted so that only half
bandwidth can be used for data recovery. As in the
GFS experiments, the maximum number of parallel
data recoveries on the network is limited to 40% of
the servers, and the minimum transfer time is set to
10 seconds (the time it takes to copy an individual
GFS object, which is 64 KBytes).
Figure 7(a) shows that the MTBU for the ring
strategy appears to have an approximately Zipﬁan
distribution as a function of the number of servers.

--- PDF page 12 ---
Thus, in order to maintain a particular MTBU, it
is necessary to grow chain length t when increasing
the number of servers.
From the graph, it seems
as though chain length needs to be increased as the
logarithm of the number of servers.
Figure 7(b) shows the MTBU for rndseq. For t >
1, rndseq has lower MTBU than ring. Compared
to ring, random placement is inferior because with
random placement there are more sets of t servers
that together store a copy of a chain, and therefore
there is a higher probability of a chain getting lost
due to failures.
However, random placement makes additional op-
portunities for parallel recovery possible if there are
enough servers. Figure 7(c) shows the MTBU for
rndpar. For few servers, rndpar performs the same
as rndseq, but the increasing opportunity for paral-
lel recovery with the number of servers improves the
MTBU, and eventually rndpar outperforms rnd-
seq, and more importantly, it outperforms ring.
6
Related Work
Scalability.
Chain replication is an example of
what Jimen´ez-Peris and Pati˜no-Mart´ınez [14] call a
ROWAA (read one, write all available) approach.
They report that ROWAA approaches provide su-
perior scaling of availability to quorum techniques,
claiming that availability of ROWAA approaches
improves exponentially with the number of repli-
cas. They also argue that non-ROWAA approaches
to replication will necessarily be inferior. Because
ROWAA approaches also exhibit better throughout
than the best known quorum systems (except for
nearly write-only applications) [14], ROWAA would
seem to be the better choice for replication in most
real settings.
Many ﬁle services trade consistency for perfor-
mance and scalability. Examples include Bayou [17],
Ficus [13], Coda [15], and Sprite [5].
Typically,
these systems allow continued operation when a net-
work partitions by oﬀering tools to ﬁx inconsisten-
cies semi-automatically. Our chain replication does
not oﬀer graceful handling of partitioned operation,
trading that instead for supporting all three of: high
performance, scalability, and strong consistency.
Large-scale peer-to-peer reliable ﬁle systems are a
relatively recent avenue of inquiry. OceanStore [6],
FARSITE [2], and PAST [19] are examples.
Of
these, only OceanStore provides strong (in fact,
transactional) consistency guarantees.
Google’s File System (GFS) [11] is a large-scale
cluster-based reliable ﬁle system intended for ap-
plications similar to those motivating the invention
of chain replication. But in GFS, concurrent over-
writes are not serialized and read operations are not
synchronized with write operations. Consequently,
diﬀerent replicas can be left in diﬀerent states, and
content returned by read operations may appear to
vanish spontaneously from GFS. Such weak seman-
tics imposes a burden on programmers of applica-
tions that use GFS.
Availability versus Consistency.
Yu and Vah-
dat [25] explore the trade-oﬀbetween consistency
and availability. They argue that even in relaxed
consistency models, it is important to stay as close
to strong consistency as possible if availability is to
be maintained in the long run. On the other hand,
Gray et al. [12] argue that systems with strong con-
sistency have unstable behavior when scaled-up, and
they propose the tentative update transaction for cir-
cumventing these scalability problems.
Amza et al. [4] present a one-copy serializable
transaction protocol that is optimized for replica-
tion. As in chain replication, updates are sent to
all replicas whereas queries are processed only by
replicas known to store all completed updates. (In
chain replication, the tail is the one replica known
to store all completed updates.) The protocol of [4]
performs as well as replication protocols that provide
weak consistency, and it scales well in the number
of replicas. No analysis is given for behavior in the
face of failures.
Replica Placement.
Previous work on replica
placement has focussed on achieving high through-
put and/or low latency rather than on supporting
high availability. Acharya and Zdonik [1] advocate
locating replicas according to predictions of future
accesses (basing those predictions on past accesses).
In the Mariposa project [23], a set of rules allows
users to specify where to create replicas, whether
to move data to the query or the query to the data,
where to cache data, and more. Consistency is trans-
actional, but no consideration is given to availabil-
ity.
Wolfson et al. consider strategies to optimize
database replica placement in order to optimize per-
formance [24].
The OceanStore project also con-
siders replica placement [10, 6] but from the CDN
(Content Distribution Network, such as Akamai)
perspective of creating as few replicas as possible
while supporting certain quality of service guaran-
tees. There is a signiﬁcant body of work (e.g., [18])
concerned with placement of web page replicas as
well, all from the perspective of reducing latency
and network load.

--- PDF page 13 ---
Douceur and Wattenhofer investigate how to max-
imize the worst-case availability of ﬁles in FAR-
SITE [2], while spreading the storage load evenly
across all servers [8, 9]. Servers are assumed to have
varying availabilities. The algorithms they consider
repeatedly swap ﬁles between machines if doing so
improves ﬁle availability. The results are of a theo-
retical nature for simple scenarios; it is unclear how
well these algorithms will work in a realistic storage
system.
7
Concluding Remarks
Chain replication supports high throughput for
query and update requests, high availability of data
objects, and strong consistency guarantees. This is
possible, in part, because storage services built us-
ing chain replication can and do exhibit transient
outages but clients cannot distinguish such outages
from lost messages. Thus, the transient outages that
chain replication introduces do not expose clients to
new failure modes—chain replication represents an
interesting balance between what failures it hides
from clients and what failures it doesn’t.
When chain replication is employed, high avail-
ability of data objects comes from carefully se-
lecting a strategy for placement of volume repli-
cas on servers. Our experiments demonstrated that
with DHT-based placement strategies, availability
is unlikely to scale with increases in the numbers
of servers; but we also demonstrated that random
placement of volumes does permit availability to
scale with the number of servers if this placement
strategy is used in concert with parallel data recov-
ery, as introduced for GFS.
Our current prototype is intended primarily for
use in relatively homogeneous LAN clusters. Were
our prototype to be deployed in a heterogeneous
wide-area setting, then uniform random placement
of volume replicas would no longer make sense. In-
stead, replica placement would have to depend on
access patterns, network proximity, and observed
host reliability. Protocols to re-order the elements
of a chain would likely become crucial in order to
control load imbalances.
Our prototype chain replication implementation
consists of 1500 lines of Java code, plus another 2300
lines of Java code for a Paxos library. The chain
replication protocols are structured as a library that
makes upcalls to a storage service (or other appli-
cation). The experiments in this paper assumed a
“null service” on a simulated network. But the li-
brary also runs over the Java socket library, so it
could be used to support a variety of storage service-
like applications.
Acknowledgements.
Thanks
to
our
colleagues
H˚akon Brug˚ard, Kjetil Jacobsen, and Knut Omang at
FAST who ﬁrst brought this problem to our attention.
Discussion with Mark Linderman and Sarah Chung were
helpful in revising an earlier version of this paper. We
are also grateful for the comments of the OSDI reviewers
and shepherd Margo Seltzer. A grant from the Research
Council of Norway to FAST ASA is noted and acknowl-
edged.
Van Renesse and Schneider are supported, in part, by
AFOSR grant F49620–03–1–0156 and DARPA/AFRL-
IFGA grant F30602–99–1–0532, although the views and
conclusions contained herein are those of the authors and
should not be interpreted as necessarily representing the
oﬃcial policies or endorsements, either expressed or im-
plied, of these organizations or the U.S. Government.
Notes
1The case where V = newVal yields a semantics
for update that is simply a ﬁle system write opera-
tion; the case where V = F(newVal, objID) amounts
to support for atomic read-modify-write operations
on objects.
Though powerful, this semantics falls
short of supporting transactions, which would allow
a request to query and/or update multiple objects
indivisibly.
2An actual implementation would probably store
the current value of the object rather than storing
the sequence of updates that produces this current
value. We employ a sequence of updates represen-
tation here because it simpliﬁes the task of arguing
that strong consistency guarantees hold.
3If HistobjID stores the current value of objID
rather than its entire history then “HistobjID · r”
should be interpreted to denote applying the update
to the object.
4If Histi
objID is the current state rather than a
sequence of updates, then ⪯is deﬁned to be the
“prior value” relation rather than the “preﬁx of”
relation.
5Actually, the placement strategy is not dis-
cussed in [11]. GFS does some load balancing that
results in an approximately even load across the
servers, and in our simulations we expect that ran-
dom placement is a good approximation of this strat-
egy.

--- PDF page 14 ---
6An unrealistically short MTBF was selected
here to facilitate running long-duration simulations.
References
[1] S. Acharya and S.B. Zdonik. An eﬃcient scheme
for dynamic data replication. Technical Report CS-
93-43, Brown University, September 1993.
[2] A. Adya, W.J. Bolosky, M. Castro, G. Cermak,
R. Chaiken, J.R. Douceur, J. Howell, J.R. Lorch,
M. Theimer, and R.P. Wattenhofer. FARSITE: Fed-
erated, Available, and Reliable Storage for an In-
completely Trusted Environment. In Proc. of the
5th Symp. on Operating Systems Design and Imple-
mentation, Boston, MA, December 2002. USENIX.
[3] P.A. Alsberg and J.D. Day. A principle for resilient
sharing of distributed resources. In Proc. of the 2nd
Int. Conf. on Software Engineering, pages 627–644,
October 1976.
[4] C. Amza, A.L. Cox, and W. Zwaenepoel.
Dis-
tributed Versioning: Consistent replication for scal-
ing back-end databases of dynamic content web
sites.
In Proc. of Middleware’03, pages 282–304,
Rio de Janeiro, Brazil, June 2003.
[5] M.G. Baker and J.K. Ousterhout. Availability in
the Sprite distributed ﬁle system. Operating Sys-
tems Review, 25(2):95–98, April 1991.
Also ap-
peared in the 4th ACM SIGOPS European Work-
shop – Fault Tolerance Support in Distributed Sys-
tems.
[6] Y. Chen, R.H. Katz, and J. Kubiatowicz. Dynamic
replica placement for scalable content delivery. In
Proc. of the 1st Int. Workshop on Peer-To-Peer
Systems, Cambridge, MA, March 2002.
[7] F. Dabek, M.F. Kaashoek, D. Karger, R. Morris,
and I. Stoica. Wide-area cooperative storage with
CFS. In Proc. of the 18th ACM Symp. on Operating
Systems Principles, Banﬀ, Canada, October 2001.
[8] J.R. Douceur and R.P. Wattenhofer. Competitive
hill-climbing strategies for replica placement in a
distributed ﬁle system.
In Proc. of the 15th In-
ternational Symposium on DIStributed Computing,
Lisbon, Portugal, October 2001.
[9] J.R. Douceur and R.P. Wattenhofer.
Optimizing
ﬁle availability in a secure serverless distributed ﬁle
system. In Proc. of the 20th Symp. on Reliable Dis-
tributed Systems. IEEE, 2001.
[10] D. Geels and J. Kubiatowicz.
Replica manage-
ment should be a game. In Proc. of the 10th Eu-
ropean SIGOPS Workshop, Saint-Emilion, France,
September 2002. ACM.
[11] S. Ghermawat, H. Gobioﬀ, and S.-T. Leung. The
Google ﬁle system. In Proc. of the 19th ACM Symp.
on Operating Systems Principles, Bolton Landing,
NY, October 2003.
[12] J. Gray, P. Helland, P. O’Neil, and D. Shasha. The
dangers of replication and a solution. In Proc. of the
International Conference on Management of Data
(SIGMOD), pages 173–182. ACM, June 1996.
[13] J.S. Heidemann and G.J. Popek. File system devel-
opment with stackable layers. ACM Transactions
on Computer Systems, 12(1):58–89, February 1994.
[14] R. Jimen´ez-Peris and M. Pati˜no-Mart´ınez. Are quo-
rums an alternative for data replication?
ACM
Transactions on Database Systems, 28(3):257–294,
September 2003.
[15] J. Kistler and M. Satyanarayanann. Disconnected
operation in the Coda ﬁle system (preliminary ver-
sion).
ACM Transactions on Computer Systems,
10(1):3–25, February 1992.
[16] L. Lamport.
The part-time parliament.
ACM
Transactions on Computer Systems, 16(2):133–169,
1998.
[17] K. Petersen, M.J. Spreitzer, D.B. Terry, M.M.
Theimer, and A.J. Demers. Flexible update propa-
gation for weakly consistent replication. In Proc. of
the 16th ACM Symp. on Operating Systems Prin-
ciples, pages 288–301, Saint-Malo, France, October
1997.
[18] L. Qiu, V.N. Padmanabhan, and G.M. Voelker. On
the placement of web server replicas. In Proc. of
the 20th INFOCOM, Anchorage, AK, March 2001.
IEEE.
[19] A. Rowstron and P. Druschel.
Storage manage-
ment and caching in PAST, a large scale, persis-
tent peer-to-peer storage utility.
In Proc. of the
18th ACM Symp. on Operating Systems Principles,
Banﬀ, Canada, October 2001.
[20] J. Saltzer, D. Reed, and D. Clark. End-to-end ar-
guments in system design. ACM Transactions on
Computer Systems, 2(4):277–288, November 1984.
[21] F.B. Schneider. Byzantine generals in action: Im-
plementing fail-stop processors. ACM Transactions
on Computer Systems, 2(2):145–154, May 1984.
[22] F.B. Schneider.
Implementing fault-tolerant ser-
vices using the state machine approach: A tutorial.
ACM Computing Surveys, 22(4):299–319, Decem-
ber 1990.
[23] M. Stonebraker, P.M. Aoki, R. Devine, W. Litwin,
and M. Olson. Mariposa: A new architecture for
distributed data. In Proc. of the 10th Int. Conf. on
Data Engineering, Houston, TX, 1994.
[24] O. Wolfson, S. Jajodia, and Y. Huang. An adaptive
data replication algorithm. ACM Transactions on
Computer Systems, 22(2):255–314, June 1997.
[25] H. Yu and A. Vahdat.
The cost and limits of
availability for replicated services. In Proc. of the
18th ACM Symp. on Operating Systems Principles,
Banﬀ, Canada, October 2001.

### homework: Question

- URL: http://nil.csail.mit.edu/6.824/2021/questions.html?q=q-cr&lec=11
- Local path: official-materials/questions/11-q-cr.html

#### Assigned Question

Give an example scenario where a client could observe incorrect results (i.e., non-linearizable) if the head of the chain would return a response to the client as soon as it received an acknowledgment from the next server in the chain (instead of the tail responding).
