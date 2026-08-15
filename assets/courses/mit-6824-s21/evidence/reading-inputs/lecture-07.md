# Reading Input: Lecture 7 - Fault Tolerance - Raft (2)

> This is a generated evidence bundle, not a finished study guide.
> Keep assigned reading ranges and source boundaries when summarizing.

## Video Sessions

- Part 7: Lecture 7 - Fault Tolerance - Raft (2) (https://www.bilibili.com/video/BV16f4y1z7kn/?p=7)

## Resources

### paper: Raft (extended) (2014), Section 7 to end (but not Section 6)

- URL: http://nil.csail.mit.edu/6.824/2021/papers/raft-extended.pdf
- Local path: official-materials/papers/raft-extended.pdf

#### Archived Content


--- PDF page 1 ---
In Search of an Understandable Consensus Algorithm
(Extended Version)
Diego Ongaro and John Ousterhout
Stanford University
Abstract
Raft is a consensus algorithm for managing a replicated
log. It produces a result equivalent to (multi-)Paxos, and
it is as efﬁcient as Paxos, but its structure is different
from Paxos; this makes Raft more understandable than
Paxos and also provides a better foundation for build-
ing practical systems. In order to enhance understandabil-
ity, Raft separates the key elements of consensus, such as
leader election, log replication, and safety, and it enforces
a stronger degree of coherency to reduce the number of
states that must be considered. Results from a user study
demonstrate that Raft is easier for students to learn than
Paxos. Raft also includes a new mechanism for changing
the cluster membership, which uses overlapping majori-
ties to guarantee safety.
1
Introduction
Consensus algorithms allow a collection of machines
to work as a coherent group that can survive the fail-
ures of some of its members. Because of this, they play a
key role in building reliable large-scale software systems.
Paxos [15, 16] has dominated the discussion of consen-
sus algorithms over the last decade: most implementations
of consensus are based on Paxos or inﬂuenced by it, and
Paxos has become the primary vehicle used to teach stu-
dents about consensus.
Unfortunately, Paxos is quite difﬁcult to understand, in
spite of numerous attempts to make it more approachable.
Furthermore, its architecture requires complex changes
to support practical systems. As a result, both system
builders and students struggle with Paxos.
After struggling with Paxos ourselves, we set out to
ﬁnd a new consensus algorithm that could provide a bet-
ter foundation for system building and education. Our ap-
proach was unusual in that our primary goal was under-
standability: could we deﬁne a consensus algorithm for
practical systems and describe it in a way that is signiﬁ-
cantly easier to learn than Paxos? Furthermore, we wanted
the algorithm to facilitate the development of intuitions
that are essential for system builders. It was important not
just for the algorithm to work, but for it to be obvious why
it works.
The result of this work is a consensus algorithm called
Raft. In designing Raft we applied speciﬁc techniques to
improve understandability,including decomposition (Raft
separates leader election, log replication, and safety) and
This tech report is an extended version of [32]; additional material is
noted with a gray bar in the margin. Published May 20, 2014.
state space reduction (relative to Paxos, Raft reduces the
degree of nondeterminism and the ways servers can be in-
consistent with each other). A user study with 43 students
at two universities shows that Raft is signiﬁcantly easier
to understand than Paxos: after learning both algorithms,
33 of these students were able to answer questions about
Raft better than questions about Paxos.
Raft is similar in many ways to existing consensus al-
gorithms (most notably, Oki and Liskov’s Viewstamped
Replication [29, 22]), but it has several novel features:
• Strong leader: Raft uses a stronger form of leader-
ship than other consensus algorithms. For example,
log entries only ﬂow from the leader to other servers.
This simpliﬁes the management of the replicated log
and makes Raft easier to understand.
• Leader election: Raft uses randomized timers to
elect leaders. This adds only a small amount of
mechanism to the heartbeats already required for any
consensus algorithm, while resolving conﬂicts sim-
ply and rapidly.
• Membership
changes:
Raft’s
mechanism
for
changing the set of servers in the cluster uses a new
joint consensus approach where the majorities of
two different conﬁgurations overlap during transi-
tions. This allows the cluster to continue operating
normally during conﬁguration changes.
We believe that Raft is superior to Paxos and other con-
sensus algorithms, both for educational purposes and as a
foundation for implementation. It is simpler and more un-
derstandable than other algorithms; it is described com-
pletely enough to meet the needs of a practical system;
it has several open-source implementations and is used
by several companies; its safety properties have been for-
mally speciﬁed and proven; and its efﬁciency is compara-
ble to other algorithms.
The remainder of the paper introduces the replicated
state machine problem (Section 2), discusses the strengths
and weaknesses of Paxos (Section 3), describes our gen-
eral approach to understandability (Section 4), presents
the Raft consensus algorithm (Sections 5–8), evaluates
Raft (Section 9), and discusses related work (Section 10).
2
Replicated state machines
Consensus algorithms typically arise in the context of
replicated state machines [37]. In this approach, state ma-
chines on a collection of servers compute identical copies
of the same state and can continue operating even if some
of the servers are down. Replicated state machines are
1

--- PDF page 2 ---
Figure 1: Replicated state machine architecture. The con-
sensus algorithm manages a replicated log containing state
machine commands from clients. The state machines process
identical sequences of commands from the logs, so they pro-
duce the same outputs.
used to solve a variety of fault tolerance problems in dis-
tributed systems. For example, large-scale systems that
have a single cluster leader, such as GFS [8], HDFS [38],
and RAMCloud [33], typically use a separate replicated
state machine to manage leader election and store conﬁg-
uration information that must survive leader crashes. Ex-
amples of replicated state machines include Chubby [2]
and ZooKeeper [11].
Replicated state machines are typically implemented
using a replicated log, as shown in Figure 1. Each server
stores a log containing a series of commands, which its
state machine executes in order. Each log contains the
same commands in the same order, so each state ma-
chine processes the same sequence of commands. Since
the state machines are deterministic, each computes the
same state and the same sequence of outputs.
Keeping the replicated log consistent is the job of the
consensus algorithm. The consensus module on a server
receives commands from clients and adds them to its log.
It communicates with the consensus modules on other
servers to ensure that every log eventually contains the
same requests in the same order, even if some servers fail.
Once commands are properly replicated, each server’s
state machine processes them in log order, and the out-
puts are returned to clients. As a result, the servers appear
to form a single, highly reliable state machine.
Consensus algorithms for practical systems typically
have the following properties:
• They ensure safety (never returning an incorrect re-
sult) under all non-Byzantine conditions, including
network delays, partitions, and packet loss, duplica-
tion, and reordering.
• They are fully functional (available) as long as any
majority of the servers are operational and can com-
municate with each other and with clients. Thus, a
typical cluster of ﬁve servers can tolerate the failure
of any two servers. Servers are assumed to fail by
stopping; they may later recover from state on stable
storage and rejoin the cluster.
• They do not depend on timing to ensure the consis-
tency of the logs: faulty clocks and extreme message
delays can, at worst, cause availability problems.
• In the common case, a command can complete as
soon as a majority of the cluster has responded to a
single round of remote procedure calls; a minority of
slow servers need not impact overall system perfor-
mance.
3
What’s wrong with Paxos?
Over the last ten years, Leslie Lamport’s Paxos proto-
col [15] has become almost synonymous with consensus:
it is the protocol most commonly taught in courses, and
most implementations of consensus use it as a starting
point. Paxos ﬁrst deﬁnes a protocol capable of reaching
agreement on a single decision, such as a single replicated
log entry. We refer to this subset as single-decree Paxos.
Paxos then combines multiple instances of this protocol to
facilitate a series of decisions such as a log (multi-Paxos).
Paxos ensures both safety and liveness, and it supports
changes in cluster membership. Its correctness has been
proven, and it is efﬁcient in the normal case.
Unfortunately, Paxos has two signiﬁcant drawbacks.
The ﬁrst drawback is that Paxos is exceptionally difﬁ-
cult to understand. The full explanation [15] is notori-
ously opaque; few people succeed in understanding it, and
only with great effort. As a result, there have been several
attempts to explain Paxos in simpler terms [16, 20, 21].
These explanations focus on the single-decree subset, yet
they are still challenging. In an informal survey of atten-
dees at NSDI 2012, we found few people who were com-
fortable with Paxos, even among seasoned researchers.
We struggled with Paxos ourselves; we were not able to
understand the complete protocol until after reading sev-
eral simpliﬁed explanations and designing our own alter-
native protocol, a process that took almost a year.
We hypothesize that Paxos’ opaqueness derives from
its choice of the single-decree subset as its foundation.
Single-decree Paxos is dense and subtle: it is divided into
two stages that do not have simple intuitive explanations
and cannot be understood independently. Because of this,
it is difﬁcult to develop intuitions about why the single-
decree protocol works. The composition rules for multi-
Paxos add signiﬁcant additional complexity and subtlety.
We believe that the overall problem of reaching consensus
on multiple decisions (i.e., a log instead of a single entry)
can be decomposed in other ways that are more direct and
obvious.
The second problem with Paxos is that it does not pro-
vide a good foundation for building practical implemen-
tations. One reason is that there is no widely agreed-
upon algorithm for multi-Paxos. Lamport’s descriptions
are mostly about single-decree Paxos; he sketched possi-
ble approaches to multi-Paxos, but many details are miss-
ing. There have been several attempts to ﬂesh out and op-
timize Paxos, such as [26], [39], and [13], but these differ
2

--- PDF page 3 ---
from each other and from Lamport’s sketches. Systems
such as Chubby [4] have implemented Paxos-like algo-
rithms, but in most cases their details have not been pub-
lished.
Furthermore, the Paxos architecture is a poor one for
building practical systems; this is another consequence of
the single-decree decomposition. For example, there is lit-
tle beneﬁt to choosing a collection of log entries indepen-
dently and then melding them into a sequential log; this
just adds complexity. It is simpler and more efﬁcient to
design a system around a log, where new entries are ap-
pended sequentially in a constrained order. Another prob-
lem is that Paxos uses a symmetric peer-to-peer approach
at its core (though it eventually suggests a weak form of
leadership as a performance optimization). This makes
sense in a simpliﬁed world where only one decision will
be made, but few practical systems use this approach. If a
series of decisions must be made, it is simpler and faster
to ﬁrst elect a leader, then have the leader coordinate the
decisions.
As a result, practical systems bear little resemblance
to Paxos. Each implementation begins with Paxos, dis-
covers the difﬁculties in implementing it, and then de-
velops a signiﬁcantly different architecture. This is time-
consuming and error-prone, and the difﬁculties of under-
standing Paxos exacerbate the problem. Paxos’ formula-
tion may be a good one for proving theorems about its cor-
rectness, but real implementations are so different from
Paxos that the proofs have little value. The following com-
ment from the Chubby implementers is typical:
There are signiﬁcant gaps between the description of
the Paxos algorithm and the needs of a real-world
system. . . . the ﬁnal system will be based on an un-
proven protocol [4].
Because of these problems, we concluded that Paxos
does not provide a good foundation either for system
building or for education. Given the importance of con-
sensus in large-scale software systems, we decided to see
if we could design an alternative consensus algorithm
with better properties than Paxos. Raft is the result of that
experiment.
4
Designing for understandability
We had several goals in designing Raft: it must provide
a complete and practical foundation for system building,
so that it signiﬁcantly reduces the amount of design work
required of developers; it must be safe under all conditions
and available under typical operating conditions; and it
must be efﬁcient for common operations. But our most
important goal—and most difﬁcult challenge—was un-
derstandability. It must be possible for a large audience to
understand the algorithm comfortably. In addition, it must
be possible to develop intuitions about the algorithm, so
that system builders can make the extensions that are in-
evitable in real-world implementations.
There were numerous points in the design of Raft
where we had to choose among alternative approaches.
In these situations we evaluated the alternatives based on
understandability: how hard is it to explain each alterna-
tive (for example, how complex is its state space, and does
it have subtle implications?), and how easy will it be for a
reader to completely understand the approach and its im-
plications?
We recognize that there is a high degree of subjectiv-
ity in such analysis; nonetheless, we used two techniques
that are generally applicable. The ﬁrst technique is the
well-known approach of problem decomposition: wher-
ever possible, we divided problems into separate pieces
that could be solved, explained, and understood relatively
independently. For example, in Raft we separated leader
election, log replication, safety, and membership changes.
Our second approach was to simplify the state space
by reducing the number of states to consider, making the
system more coherent and eliminating nondeterminism
where possible. Speciﬁcally, logs are not allowed to have
holes, and Raft limits the ways in which logs can become
inconsistent with each other. Although in most cases we
tried to eliminate nondeterminism, there are some situ-
ations where nondeterminism actually improves under-
standability. In particular, randomized approaches intro-
duce nondeterminism, but they tend to reduce the state
space by handling all possible choices in a similar fashion
(“choose any; it doesn’t matter”). We used randomization
to simplify the Raft leader election algorithm.
5
The Raft consensus algorithm
Raft is an algorithm for managing a replicated log of
the form described in Section 2. Figure 2 summarizes the
algorithm in condensed form for reference, and Figure 3
lists key properties of the algorithm; the elements of these
ﬁgures are discussed piecewise over the rest of this sec-
tion.
Raft implements consensus by ﬁrst electing a distin-
guished leader, then giving the leader complete responsi-
bility for managing the replicated log. The leader accepts
log entries from clients, replicates them on other servers,
and tells servers when it is safe to apply log entries to
their state machines. Having a leader simpliﬁes the man-
agement of the replicated log. For example, the leader can
decide where to place new entries in the log without con-
sulting other servers, and data ﬂows in a simple fashion
from the leader to other servers. A leader can fail or be-
come disconnected from the other servers, in which case
a new leader is elected.
Given the leader approach, Raft decomposes the con-
sensus problem into three relatively independent subprob-
lems, which are discussed in the subsections that follow:
• Leader election: a new leader must be chosen when
an existing leader fails (Section 5.2).
• Log replication: the leader must accept log entries
3

--- PDF page 4 ---
Invoked by candidates to gather votes (§5.2).
Arguments:
term
candidate’s term
candidateId
candidate requesting vote
lastLogIndex
index of candidate’s last log entry (§5.4)
lastLogTerm
term of candidate’s last log entry (§5.4)
Results:
term
currentTerm, for candidate to update itself
voteGranted
true means candidate received vote
Receiver implementation:
1.
Reply false if term < currentTerm (§5.1)
2.
If votedFor is null or candidateId, and candidate’s log is at
least as up-to-date as receiver’s log, grant vote (§5.2, §5.4)
RequestVote RPC
Invoked by leader to replicate log entries (§5.3); also used as
heartbeat (§5.2).
Arguments:
term
leader’s term
leaderId
so follower can redirect clients
prevLogIndex
index of log entry immediately preceding
new ones
prevLogTerm
term of prevLogIndex entry
entries[]
log entries to store (empty for heartbeat;
may send more than one for efficiency)
leaderCommit
leader’s commitIndex
Results:
term
currentTerm, for leader to update itself
success
true if follower contained entry matching
prevLogIndex and prevLogTerm
Receiver implementation:
1.
Reply false if term < currentTerm (§5.1)
2.
Reply false if log doesn’t contain an entry at prevLogIndex
whose term matches prevLogTerm (§5.3)
3.
If an existing entry conflicts with a new one (same index
but different terms), delete the existing entry and all that
follow it (§5.3)
4.
Append any new entries not already in the log
5.
If leaderCommit > commitIndex, set commitIndex =
min(leaderCommit, index of last new entry)
AppendEntries RPC
Persistent state on all servers:
(Updated on stable storage before responding to RPCs)
currentTerm
latest term server has seen (initialized to 0
on first boot, increases monotonically)
votedFor
candidateId that received vote in current
term (or null if none)
log[]
log entries; each entry contains command
for state machine, and term when entry
was received by leader (first index is 1)
Volatile state on all servers:
commitIndex
index of highest log entry known to be
committed (initialized to 0, increases
monotonically)
lastApplied
index of highest log entry applied to state
machine (initialized to 0, increases
monotonically)
Volatile state on leaders:
(Reinitialized after election)
nextIndex[]
for each server, index of the next log entry
to send to that server (initialized to leader
last log index + 1)
matchIndex[]
for each server, index of highest log entry
known to be replicated on server
(initialized to 0, increases monotonically)
State
All Servers:
•
If commitIndex > lastApplied: increment lastApplied, apply
log[lastApplied] to state machine (§5.3)
•
If RPC request or response contains term T > currentTerm:
set currentTerm = T, convert to follower (§5.1)
Followers (§5.2):
•
Respond to RPCs from candidates and leaders
•
If election timeout elapses without receiving AppendEntries
RPC from current leader or granting vote to candidate:
convert to candidate
Candidates (§5.2):
•
On conversion to candidate, start election:
• Increment currentTerm
• Vote for self
• Reset election timer
• Send RequestVote RPCs to all other servers
•
If votes received from majority of servers: become leader
•
If AppendEntries RPC received from new leader: convert to
follower
•
If election timeout elapses: start new election
Leaders:
•
Upon election: send initial empty AppendEntries RPCs
(heartbeat) to each server; repeat during idle periods to
prevent election timeouts (§5.2)
•
If command received from client: append entry to local log,
respond after entry applied to state machine (§5.3)
•
If last log index ≥nextIndex for a follower: send
AppendEntries RPC with log entries starting at nextIndex
• If successful: update nextIndex and matchIndex for
follower (§5.3)
• If AppendEntries fails because of log inconsistency:
decrement nextIndex and retry (§5.3)
•
If there exists an N such that N > commitIndex, a majority
of matchIndex[i] ≥N, and log[N].term == currentTerm:
set commitIndex = N (§5.3, §5.4).
Rules for Servers
Figure 2: A condensed summary of the Raft consensus algorithm (excluding membership changes and log compaction). The server
behavior in the upper-left box is described as a set of rules that trigger independently and repeatedly. Section numbers such as §5.2
indicate where particular features are discussed. A formal speciﬁcation [31] describes the algorithm more precisely.
4

--- PDF page 5 ---
Election Safety: at most one leader can be elected in a
given term. §5.2
Leader Append-Only: a leader never overwrites or deletes
entries in its log; it only appends new entries. §5.3
Log Matching: if two logs contain an entry with the same
index and term, then the logs are identical in all entries
up through the given index. §5.3
Leader Completeness: if a log entry is committed in a
given term, then that entry will be present in the logs
of the leaders for all higher-numbered terms. §5.4
State Machine Safety: if a server has applied a log entry
at a given index to its state machine, no other server
will ever apply a different log entry for the same index.
§5.4.3
Figure 3: Raft guarantees that each of these properties is true
at all times. The section numbers indicate where each prop-
erty is discussed.
from clients and replicate them across the cluster,
forcing the other logs to agree with its own (Sec-
tion 5.3).
• Safety: the key safety property for Raft is the State
Machine Safety Property in Figure 3: if any server
has applied a particular log entry to its state machine,
then no other server may apply a different command
for the same log index. Section 5.4 describes how
Raft ensures this property; the solution involves an
additional restriction on the election mechanism de-
scribed in Section 5.2.
After presenting the consensus algorithm, this section dis-
cusses the issue of availability and the role of timing in the
system.
5.1
Raft basics
A Raft cluster contains several servers; ﬁve is a typical
number, which allows the system to tolerate two failures.
At any given time each server is in one of three states:
leader, follower, or candidate. In normal operation there
is exactly one leader and all of the other servers are fol-
lowers. Followers are passive: they issue no requests on
their own but simply respond to requests from leaders
and candidates. The leader handles all client requests (if
a client contacts a follower, the follower redirects it to the
leader). The third state, candidate, is used to elect a new
leader as described in Section 5.2. Figure 4 shows the
states and their transitions; the transitions are discussed
below.
Raft divides time into terms of arbitrary length, as
shown in Figure 5. Terms are numbered with consecutive
integers. Each term begins with an election, in which one
or more candidates attempt to become leader as described
in Section 5.2. If a candidate wins the election, then it
serves as leader for the rest of the term. In some situations
an election will result in a split vote. In this case the term
will end with no leader; a new term (with a new election)
Figure 4: Server states. Followers only respond to requests
from other servers. If a follower receives no communication,
it becomes a candidate and initiates an election. A candidate
that receives votes from a majority of the full cluster becomes
the new leader. Leaders typically operate until they fail.
Figure 5: Time is divided into terms, and each term begins
with an election. After a successful election, a single leader
manages the cluster until the end of the term. Some elections
fail, in which case the term ends without choosing a leader.
The transitions between terms may be observed at different
times on different servers.
will begin shortly. Raft ensures that there is at most one
leader in a given term.
Different servers may observe the transitions between
terms at different times, and in some situations a server
may not observe an election or even entire terms. Terms
act as a logical clock [14] in Raft, and they allow servers
to detect obsolete information such as stale leaders. Each
server stores a current term number, which increases
monotonically over time. Current terms are exchanged
whenever servers communicate; if one server’s current
term is smaller than the other’s, then it updates its current
term to the larger value. If a candidate or leader discovers
that its term is out of date, it immediately reverts to fol-
lower state. If a server receives a request with a stale term
number, it rejects the request.
Raft servers communicate using remote procedure calls
(RPCs), and the basic consensus algorithm requires only
two types of RPCs. RequestVote RPCs are initiated by
candidates during elections (Section 5.2), and Append-
Entries RPCs are initiated by leaders to replicate log en-
tries and to provide a form of heartbeat (Section 5.3). Sec-
tion 7 adds a third RPC for transferring snapshots between
servers. Servers retry RPCs if they do not receive a re-
sponse in a timely manner, and they issue RPCs in parallel
for best performance.
5.2
Leader election
Raft uses a heartbeat mechanism to trigger leader elec-
tion. When servers start up, they begin as followers. A
server remains in follower state as long as it receives valid
5

--- PDF page 6 ---
RPCs from a leader or candidate. Leaders send periodic
heartbeats (AppendEntries RPCs that carry no log entries)
to all followers in order to maintain their authority. If a
follower receives no communication over a period of time
called the election timeout, then it assumes there is no vi-
able leader and begins an election to choose a new leader.
To begin an election, a follower increments its current
term and transitions to candidate state. It then votes for
itself and issues RequestVote RPCs in parallel to each of
the other servers in the cluster. A candidate continues in
this state until one of three things happens: (a) it wins the
election, (b) another server establishes itself as leader, or
(c) a period of time goes by with no winner. These out-
comes are discussed separately in the paragraphs below.
A candidate wins an election if it receives votes from
a majority of the servers in the full cluster for the same
term. Each server will vote for at most one candidate in a
given term, on a ﬁrst-come-ﬁrst-served basis (note: Sec-
tion 5.4 adds an additional restriction on votes). The ma-
jority rule ensures that at most one candidate can win the
election for a particular term (the Election Safety Prop-
erty in Figure 3). Once a candidate wins an election, it
becomes leader. It then sends heartbeat messages to all of
the other servers to establish its authority and prevent new
elections.
While waiting for votes, a candidate may receive an
AppendEntries RPC from another server claiming to be
leader. If the leader’s term (included in its RPC) is at least
as large as the candidate’s current term, then the candidate
recognizes the leader as legitimate and returns to follower
state. If the term in the RPC is smaller than the candidate’s
current term, then the candidate rejects the RPC and con-
tinues in candidate state.
The third possible outcome is that a candidate neither
wins nor loses the election: if many followers become
candidates at the same time, votes could be split so that
no candidate obtains a majority. When this happens, each
candidate will time out and start a new election by incre-
menting its term and initiating another round of Request-
Vote RPCs. However, without extra measures split votes
could repeat indeﬁnitely.
Raft uses randomized election timeouts to ensure that
split votes are rare and that they are resolved quickly. To
prevent split votes in the ﬁrst place, election timeouts are
chosen randomly from a ﬁxed interval (e.g., 150–300ms).
This spreads out the servers so that in most cases only a
single server will time out; it wins the election and sends
heartbeats before any other servers time out. The same
mechanism is used to handle split votes. Each candidate
restarts its randomized election timeout at the start of an
election, and it waits for that timeout to elapse before
starting the next election; this reduces the likelihood of
another split vote in the new election. Section 9.3 shows
that this approach elects a leader rapidly.
Figure 6: Logs are composed of entries, which are numbered
sequentially. Each entry contains the term in which it was
created (the number in each box) and a command for the state
machine. An entry is considered committed if it is safe for that
entry to be applied to state machines.
Elections are an example of how understandability
guided our choice between design alternatives. Initially
we planned to use a ranking system: each candidate was
assigned a unique rank, which was used to select between
competing candidates. If a candidate discovered another
candidate with higher rank, it would return to follower
state so that the higher ranking candidate could more eas-
ily win the next election. We found that this approach
created subtle issues around availability (a lower-ranked
server might need to time out and become a candidate
again if a higher-ranked server fails, but if it does so too
soon, it can reset progress towards electing a leader). We
made adjustments to the algorithm several times, but after
each adjustment new corner cases appeared. Eventually
we concluded that the randomized retry approach is more
obvious and understandable.
5.3
Log replication
Once a leader has been elected, it begins servicing
client requests. Each client request contains a command to
be executed by the replicated state machines. The leader
appends the command to its log as a new entry, then is-
sues AppendEntries RPCs in parallel to each of the other
servers to replicate the entry. When the entry has been
safely replicated (as described below), the leader applies
the entry to its state machine and returns the result of that
execution to the client. If followers crash or run slowly,
or if network packets are lost, the leader retries Append-
Entries RPCs indeﬁnitely (even after it has responded to
the client) until all followers eventually store all log en-
tries.
Logs are organized as shown in Figure 6. Each log en-
try stores a state machine command along with the term
number when the entry was received by the leader. The
term numbers in log entries are used to detect inconsis-
tencies between logs and to ensure some of the properties
in Figure 3. Each log entry also has an integer index iden-
6

--- PDF page 7 ---
tifying its position in the log.
The leader decides when it is safe to apply a log en-
try to the state machines; such an entry is called commit-
ted. Raft guarantees that committed entries are durable
and will eventually be executed by all of the available
state machines. A log entry is committed once the leader
that created the entry has replicated it on a majority of
the servers (e.g., entry 7 in Figure 6). This also commits
all preceding entries in the leader’s log, including entries
created by previous leaders. Section 5.4 discusses some
subtleties when applying this rule after leader changes,
and it also shows that this deﬁnition of commitment is
safe. The leader keeps track of the highest index it knows
to be committed, and it includes that index in future
AppendEntries RPCs (including heartbeats) so that the
other servers eventually ﬁnd out. Once a follower learns
that a log entry is committed, it applies the entry to its
local state machine (in log order).
We designed the Raft log mechanism to maintain a high
level of coherency between the logs on different servers.
Not only does this simplify the system’s behavior and
make it more predictable, but it is an important component
of ensuring safety. Raft maintains the following proper-
ties, which together constitute the Log Matching Property
in Figure 3:
• If two entries in different logs have the same index
and term, then they store the same command.
• If two entries in different logs have the same index
and term, then the logs are identical in all preceding
entries.
The ﬁrst property follows from the fact that a leader
creates at most one entry with a given log index in a given
term, and log entries never change their position in the
log. The second property is guaranteed by a simple con-
sistency check performed by AppendEntries. When send-
ing an AppendEntries RPC, the leader includes the index
and term of the entry in its log that immediately precedes
the new entries. If the follower does not ﬁnd an entry in
its log with the same index and term, then it refuses the
new entries. The consistency check acts as an induction
step: the initial empty state of the logs satisﬁes the Log
Matching Property, and the consistency check preserves
the Log Matching Property whenever logs are extended.
As a result, whenever AppendEntries returns successfully,
the leader knows that the follower’s log is identical to its
own log up through the new entries.
During normal operation, the logs of the leader and
followers stay consistent, so the AppendEntries consis-
tency check never fails. However, leader crashes can leave
the logs inconsistent (the old leader may not have fully
replicated all of the entries in its log). These inconsisten-
cies can compound over a series of leader and follower
crashes. Figure 7 illustrates the ways in which followers’
logs may differ from that of a new leader. A follower may
Figure 7: When the leader at the top comes to power, it is
possible that any of scenarios (a–f) could occur in follower
logs. Each box represents one log entry; the number in the
box is its term. A follower may be missing entries (a–b), may
have extra uncommitted entries (c–d), or both (e–f). For ex-
ample, scenario (f) could occur if that server was the leader
for term 2, added several entries to its log, then crashed before
committing any of them; it restarted quickly, became leader
for term 3, and added a few more entries to its log; before any
of the entries in either term 2 or term 3 were committed, the
server crashed again and remained down for several terms.
be missing entries that are present on the leader, it may
have extra entries that are not present on the leader, or
both. Missing and extraneous entries in a log may span
multiple terms.
In Raft, the leader handles inconsistencies by forcing
the followers’ logs to duplicate its own. This means that
conﬂicting entries in follower logs will be overwritten
with entries from the leader’s log. Section 5.4 will show
that this is safe when coupled with one more restriction.
To bring a follower’s log into consistency with its own,
the leader must ﬁnd the latest log entry where the two
logs agree, delete any entries in the follower’s log after
that point, and send the follower all of the leader’s entries
after that point. All of these actions happen in response
to the consistency check performed by AppendEntries
RPCs. The leader maintains a nextIndex for each follower,
which is the index of the next log entry the leader will
send to that follower. When a leader ﬁrst comes to power,
it initializes all nextIndex values to the index just after the
last one in its log (11 in Figure 7). If a follower’s log is
inconsistent with the leader’s, the AppendEntries consis-
tency check will fail in the next AppendEntries RPC. Af-
ter a rejection, the leader decrements nextIndex and retries
the AppendEntries RPC. Eventually nextIndex will reach
a point where the leader and follower logs match. When
this happens, AppendEntries will succeed, which removes
any conﬂicting entries in the follower’s log and appends
entries from the leader’s log (if any). Once AppendEntries
succeeds, the follower’s log is consistent with the leader’s,
and it will remain that way for the rest of the term.
If desired, the protocol can be optimized to reduce the
number of rejected AppendEntries RPCs. For example,
when rejecting an AppendEntries request, the follower
7

--- PDF page 8 ---
can include the term of the conﬂicting entry and the ﬁrst
index it stores for that term. With this information, the
leader can decrement nextIndex to bypass all of the con-
ﬂicting entries in that term; one AppendEntries RPC will
be required for each term with conﬂicting entries, rather
than one RPC per entry. In practice, we doubt this opti-
mization is necessary, since failures happen infrequently
and it is unlikely that there will be many inconsistent en-
tries.
With this mechanism, a leader does not need to take any
special actions to restore log consistency when it comes to
power. It just begins normal operation, and the logs auto-
matically converge in response to failures of the Append-
Entries consistency check. A leader never overwrites or
deletes entries in its own log (the Leader Append-Only
Property in Figure 3).
This log replication mechanism exhibits the desirable
consensus properties described in Section 2: Raft can ac-
cept, replicate, and apply new log entries as long as a ma-
jority of the servers are up; in the normal case a new entry
can be replicated with a single round of RPCs to a ma-
jority of the cluster; and a single slow follower will not
impact performance.
5.4
Safety
The previous sections described how Raft elects lead-
ers and replicates log entries. However, the mechanisms
described so far are not quite sufﬁcient to ensure that each
state machine executes exactly the same commands in the
same order. For example, a follower might be unavailable
while the leader commits several log entries, then it could
be elected leader and overwrite these entries with new
ones; as a result, different state machines might execute
different command sequences.
This section completes the Raft algorithm by adding a
restriction on which servers may be elected leader. The
restriction ensures that the leader for any given term con-
tains all of the entries committed in previous terms (the
Leader Completeness Property from Figure 3). Given the
election restriction, we then make the rules for commit-
ment more precise. Finally, we present a proof sketch for
the Leader Completeness Property and show how it leads
to correct behavior of the replicated state machine.
5.4.1
Election restriction
In any leader-based consensus algorithm, the leader
must eventually store all of the committed log entries. In
some consensus algorithms, such as Viewstamped Repli-
cation [22], a leader can be elected even if it doesn’t
initially contain all of the committed entries. These al-
gorithms contain additional mechanisms to identify the
missing entries and transmit them to the new leader, ei-
ther during the election process or shortly afterwards. Un-
fortunately, this results in considerable additional mecha-
nism and complexity. Raft uses a simpler approach where
it guarantees that all the committed entries from previous
Figure 8: A time sequence showing why a leader cannot de-
termine commitment using log entries from older terms. In
(a) S1 is leader and partially replicates the log entry at index
2. In (b) S1 crashes; S5 is elected leader for term 3 with votes
from S3, S4, and itself, and accepts a different entry at log
index 2. In (c) S5 crashes; S1 restarts, is elected leader, and
continues replication. At this point, the log entry from term 2
has been replicated on a majority of the servers, but it is not
committed. If S1 crashes as in (d), S5 could be elected leader
(with votes from S2, S3, and S4) and overwrite the entry with
its own entry from term 3. However, if S1 replicates an en-
try from its current term on a majority of the servers before
crashing, as in (e), then this entry is committed (S5 cannot
win an election). At this point all preceding entries in the log
are committed as well.
terms are present on each new leader from the moment of
its election, without the need to transfer those entries to
the leader. This means that log entries only ﬂow in one di-
rection, from leaders to followers, and leaders never over-
write existing entries in their logs.
Raft uses the voting process to prevent a candidate from
winning an election unless its log contains all committed
entries. A candidate must contact a majority of the cluster
in order to be elected, which means that every committed
entry must be present in at least one of those servers. If the
candidate’s log is at least as up-to-date as any other log
in that majority (where “up-to-date” is deﬁned precisely
below), then it will hold all the committed entries. The
RequestVote RPC implements this restriction: the RPC
includes information about the candidate’s log, and the
voter denies its vote if its own log is more up-to-date than
that of the candidate.
Raft determines which of two logs is more up-to-date
by comparing the index and term of the last entries in the
logs. If the logs have last entries with different terms, then
the log with the later term is more up-to-date. If the logs
end with the same term, then whichever log is longer is
more up-to-date.
5.4.2
Committing entries from previous terms
As described in Section 5.3, a leader knows that an en-
try from its current term is committed once that entry is
stored on a majority of the servers. If a leader crashes be-
fore committing an entry, future leaders will attempt to
ﬁnish replicating the entry. However, a leader cannot im-
mediately conclude that an entry from a previous term is
committed once it is stored on a majority of servers. Fig-
8

--- PDF page 9 ---
Figure 9: If S1 (leader for term T) commits a new log entry
from its term, and S5 is elected leader for a later term U, then
there must be at least one server (S3) that accepted the log
entry and also voted for S5.
ure 8 illustrates a situation where an old log entry is stored
on a majority of servers, yet can still be overwritten by a
future leader.
To eliminate problems like the one in Figure 8, Raft
never commits log entries from previous terms by count-
ing replicas. Only log entries from the leader’s current
term are committed by counting replicas; once an entry
from the current term has been committed in this way,
then all prior entries are committed indirectly because
of the Log Matching Property. There are some situations
where a leader could safely conclude that an older log en-
try is committed (for example, if that entry is stored on ev-
ery server), but Raft takes a more conservative approach
for simplicity.
Raft incurs this extra complexity in the commitment
rules because log entries retain their original term num-
bers when a leader replicates entries from previous
terms. In other consensus algorithms, if a new leader re-
replicates entries from prior “terms,” it must do so with
its new “term number.” Raft’s approach makes it easier
to reason about log entries, since they maintain the same
term number over time and across logs. In addition, new
leaders in Raft send fewer log entries from previous terms
than in other algorithms (other algorithms must send re-
dundant log entries to renumber them before they can be
committed).
5.4.3
Safety argument
Given the complete Raft algorithm, we can now ar-
gue more precisely that the Leader Completeness Prop-
erty holds (this argument is based on the safety proof; see
Section 9.2). We assume that the Leader Completeness
Property does not hold, then we prove a contradiction.
Suppose the leader for term T (leaderT) commits a log
entry from its term, but that log entry is not stored by the
leader of some future term. Consider the smallest term U
> T whose leader (leaderU) does not store the entry.
1. The committed entry must have been absent from
leaderU’s log at the time of its election (leaders never
delete or overwrite entries).
2. leaderT replicated the entry on a majority of the clus-
ter, and leaderU received votes from a majority of
the cluster. Thus, at least one server (“the voter”)
both accepted the entry from leaderT and voted for
leaderU, as shown in Figure 9. The voter is key to
reaching a contradiction.
3. The voter must have accepted the committed entry
from leaderT before voting for leaderU; otherwise it
would have rejected the AppendEntries request from
leaderT (its current term would have been higher than
T).
4. The voter still stored the entry when it voted for
leaderU, since every intervening leader contained the
entry (by assumption), leaders never remove entries,
and followers only remove entries if they conﬂict
with the leader.
5. The voter granted its vote to leaderU, so leaderU’s
log must have been as up-to-date as the voter’s. This
leads to one of two contradictions.
6. First, if the voter and leaderU shared the same last
log term, then leaderU’s log must have been at least
as long as the voter’s, so its log contained every entry
in the voter’s log. This is a contradiction, since the
voter contained the committed entry and leaderU was
assumed not to.
7. Otherwise, leaderU’s last log term must have been
larger than the voter’s. Moreover, it was larger than
T, since the voter’s last log term was at least T (it con-
tains the committed entry from term T). The earlier
leader that created leaderU’s last log entry must have
contained the committed entry in its log (by assump-
tion). Then, by the Log Matching Property, leaderU’s
log must also contain the committed entry, which is
a contradiction.
8. This completes the contradiction. Thus, the leaders
of all terms greater than T must contain all entries
from term T that are committed in term T.
9. The Log Matching Property guarantees that future
leaders will also contain entries that are committed
indirectly, such as index 2 in Figure 8(d).
Given the Leader Completeness Property, we can prove
the State Machine Safety Property from Figure 3, which
states that if a server has applied a log entry at a given
index to its state machine, no other server will ever apply a
different log entry for the same index. At the time a server
applies a log entry to its state machine, its log must be
identical to the leader’s log up through that entry and the
entry must be committed. Now consider the lowest term
in which any server applies a given log index; the Log
Completeness Property guarantees that the leaders for all
higher terms will store that same log entry, so servers that
apply the index in later terms will apply the same value.
Thus, the State Machine Safety Property holds.
Finally, Raft requires servers to apply entries in log in-
dex order. Combined with the State Machine Safety Prop-
erty, this means that all servers will apply exactly the same
set of log entries to their state machines, in the same order.
9

--- PDF page 10 ---
5.5
Follower and candidate crashes
Until this point we have focused on leader failures. Fol-
lower and candidate crashes are much simpler to han-
dle than leader crashes, and they are both handled in the
same way. If a follower or candidate crashes, then fu-
ture RequestVote and AppendEntries RPCs sent to it will
fail. Raft handles these failures by retrying indeﬁnitely;
if the crashed server restarts, then the RPC will complete
successfully. If a server crashes after completing an RPC
but before responding, then it will receive the same RPC
again after it restarts. Raft RPCs are idempotent, so this
causes no harm. For example, if a follower receives an
AppendEntries request that includes log entries already
present in its log, it ignores those entries in the new re-
quest.
5.6
Timing and availability
One of our requirements for Raft is that safety must
not depend on timing: the system must not produce incor-
rect results just because some event happens more quickly
or slowly than expected. However, availability (the ability
of the system to respond to clients in a timely manner)
must inevitably depend on timing. For example, if mes-
sage exchanges take longer than the typical time between
server crashes, candidates will not stay up long enough to
win an election; without a steady leader, Raft cannot make
progress.
Leader election is the aspect of Raft where timing is
most critical. Raft will be able to elect and maintain a
steady leader as long as the system satisﬁes the follow-
ing timing requirement:
broadcastTime ≪electionTimeout ≪MTBF
In this inequality broadcastTime is the average time it
takes a server to send RPCs in parallel to every server
in the cluster and receive their responses; electionTime-
out is the election timeout described in Section 5.2; and
MTBF is the average time between failures for a single
server. The broadcast time should be an order of mag-
nitude less than the election timeout so that leaders can
reliably send the heartbeat messages required to keep fol-
lowers from starting elections; given the randomized ap-
proach used for election timeouts, this inequality also
makes split votes unlikely. The election timeout should be
a few orders of magnitude less than MTBF so that the sys-
tem makes steady progress. When the leader crashes, the
system will be unavailable for roughly the election time-
out; we would like this to represent only a small fraction
of overall time.
The broadcast time and MTBF are properties of the un-
derlying system, while the election timeout is something
we must choose. Raft’s RPCs typically require the recip-
ient to persist information to stable storage, so the broad-
cast time may range from 0.5ms to 20ms, depending on
storage technology. As a result, the election timeout is
likely to be somewhere between 10ms and 500ms. Typical
Figure 10: Switching directly from one conﬁguration to an-
other is unsafe because different servers will switch at dif-
ferent times. In this example, the cluster grows from three
servers to ﬁve. Unfortunately, there is a point in time where
two different leaders can be elected for the same term, one
with a majority of the old conﬁguration (Cold) and another
with a majority of the new conﬁguration (Cnew).
server MTBFs are several months or more, which easily
satisﬁes the timing requirement.
6
Cluster membership changes
Up until now we have assumed that the cluster conﬁg-
uration (the set of servers participating in the consensus
algorithm) is ﬁxed. In practice, it will occasionally be nec-
essary to change the conﬁguration, for example to replace
servers when they fail or to change the degree of replica-
tion. Although this can be done by taking the entire cluster
off-line, updating conﬁguration ﬁles, and then restarting
the cluster, this would leave the cluster unavailable dur-
ing the changeover. In addition, if there are any manual
steps, they risk operator error. In order to avoid these is-
sues, we decided to automate conﬁguration changes and
incorporate them into the Raft consensus algorithm.
For the conﬁguration change mechanism to be safe,
there must be no point during the transition where it
is possible for two leaders to be elected for the same
term. Unfortunately, any approach where servers switch
directly from the old conﬁguration to the new conﬁgura-
tion is unsafe. It isn’t possible to atomically switch all of
the servers at once, so the cluster can potentially split into
two independent majorities during the transition (see Fig-
ure 10).
In order to ensure safety, conﬁguration changes must
use a two-phase approach. There are a variety of ways
to implement the two phases. For example, some systems
(e.g., [22]) use the ﬁrst phase to disable the old conﬁgura-
tion so it cannot process client requests; then the second
phase enables the new conﬁguration. In Raft the cluster
ﬁrst switches to a transitional conﬁguration we call joint
consensus; once the joint consensus has been committed,
the system then transitions to the new conﬁguration. The
joint consensus combines both the old and new conﬁgu-
rations:
• Log entries are replicated to all servers in both con-
ﬁgurations.
10

--- PDF page 11 ---
Figure 11: Timeline for a conﬁguration change. Dashed lines
show conﬁguration entries that have been created but not
committed, and solid lines show the latest committed conﬁgu-
ration entry. The leader ﬁrst creates the Cold,new conﬁguration
entry in its log and commits it to Cold,new (a majority of Cold
and a majority of Cnew). Then it creates the Cnew entry and
commits it to a majority of Cnew. There is no point in time in
which Cold and Cnew can both make decisions independently.
• Any server from either conﬁguration may serve as
leader.
• Agreement (for elections and entry commitment) re-
quires separate majorities from both the old and new
conﬁgurations.
The joint consensus allows individual servers to transition
between conﬁgurations at different times without com-
promising safety. Furthermore, joint consensus allows the
cluster to continue servicing client requests throughout
the conﬁguration change.
Cluster conﬁgurations are stored and communicated
using special entries in the replicated log; Figure 11 illus-
trates the conﬁguration change process. When the leader
receives a request to change the conﬁguration from Cold
to Cnew, it stores the conﬁguration for joint consensus
(Cold,new in the ﬁgure) as a log entry and replicates that
entry using the mechanisms described previously. Once a
given server adds the new conﬁguration entry to its log,
it uses that conﬁguration for all future decisions (a server
always uses the latest conﬁguration in its log, regardless
of whether the entry is committed). This means that the
leader will use the rules of Cold,new to determine when the
log entry for Cold,new is committed. If the leader crashes,
a new leader may be chosen under either Cold or Cold,new,
depending on whether the winning candidate has received
Cold,new. In any case, Cnew cannot make unilateral deci-
sions during this period.
OnceCold,new has been committed, neitherCold norCnew
can make decisions without approval of the other, and the
Leader Completeness Property ensures that only servers
with the Cold,new log entry can be elected as leader. It is
now safe for the leader to create a log entry describing
Cnew and replicate it to the cluster. Again, this conﬁgura-
tion will take effect on each server as soon as it is seen.
When the new conﬁguration has been committed under
the rules of Cnew, the old conﬁguration is irrelevant and
servers not in the new conﬁguration can be shut down. As
shown in Figure 11, there is no time when Cold and Cnew
can both make unilateral decisions; this guarantees safety.
There are three more issues to address for reconﬁgura-
tion. The ﬁrst issue is that new servers may not initially
store any log entries. If they are added to the cluster in
this state, it could take quite a while for them to catch
up, during which time it might not be possible to com-
mit new log entries. In order to avoid availability gaps,
Raft introduces an additional phase before the conﬁgu-
ration change, in which the new servers join the cluster
as non-voting members (the leader replicates log entries
to them, but they are not considered for majorities). Once
the new servers have caught up with the rest of the cluster,
the reconﬁguration can proceed as described above.
The second issue is that the cluster leader may not be
part of the new conﬁguration. In this case, the leader steps
down (returns to follower state) once it has committed the
Cnew log entry. This means that there will be a period of
time (while it is committingCnew) when the leader is man-
aging a cluster that does not include itself; it replicates log
entries but does not count itself in majorities. The leader
transition occurs when Cnew is committed because this is
the ﬁrst point when the new conﬁguration can operate in-
dependently (it will always be possible to choose a leader
from Cnew). Before this point, it may be the case that only
a server from Cold can be elected leader.
The third issue is that removed servers (those not in
Cnew) can disrupt the cluster. These servers will not re-
ceive heartbeats, so they will time out and start new elec-
tions. They will then send RequestVote RPCs with new
term numbers, and this will cause the current leader to
revert to follower state. A new leader will eventually be
elected, but the removed servers will time out again and
the process will repeat, resulting in poor availability.
To prevent this problem, servers disregard RequestVote
RPCs when they believe a current leader exists. Specif-
ically, if a server receives a RequestVote RPC within
the minimum election timeout of hearing from a cur-
rent leader, it does not update its term or grant its vote.
This does not affect normal elections, where each server
waits at least a minimum election timeout before starting
an election. However, it helps avoid disruptions from re-
moved servers: if a leader is able to get heartbeats to its
cluster, then it will not be deposed by larger term num-
bers.
7
Log compaction
Raft’s log grows during normal operation to incorpo-
rate more client requests, but in a practical system, it can-
not grow without bound. As the log grows longer, it oc-
cupies more space and takes more time to replay. This
will eventually cause availability problems without some
mechanism to discard obsolete information that has accu-
mulated in the log.
Snapshotting is the simplest approach to compaction.
In snapshotting, the entire current system state is written
to a snapshot on stable storage, then the entire log up to
11

--- PDF page 12 ---
Figure 12: A server replaces the committed entries in its log
(indexes 1 through 5) with a new snapshot, which stores just
the current state (variables x and y in this example). The snap-
shot’s last included index and term serve to position the snap-
shot in the log preceding entry 6.
that point is discarded. Snapshotting is used in Chubby
and ZooKeeper, and the remainder of this section de-
scribes snapshotting in Raft.
Incremental approaches to compaction, such as log
cleaning [36] and log-structured merge trees [30, 5], are
also possible. These operate on a fraction of the data at
once, so they spread the load of compaction more evenly
over time. They ﬁrst select a region of data that has ac-
cumulated many deleted and overwritten objects, then
they rewrite the live objects from that region more com-
pactly and free the region. This requires signiﬁcant addi-
tional mechanism and complexity compared to snapshot-
ting, which simpliﬁes the problem by always operating
on the entire data set. While log cleaning would require
modiﬁcations to Raft, state machines can implement LSM
trees using the same interface as snapshotting.
Figure 12 shows the basic idea of snapshotting in Raft.
Each server takes snapshots independently, covering just
the committed entries in its log. Most of the work con-
sists of the state machine writing its current state to the
snapshot. Raft also includes a small amount of metadata
in the snapshot: the last included index is the index of the
last entry in the log that the snapshot replaces (the last en-
try the state machine had applied), and the last included
term is the term of this entry. These are preserved to sup-
port the AppendEntries consistency check for the ﬁrst log
entry following the snapshot, since that entry needs a pre-
vious log index and term. To enable cluster membership
changes (Section 6), the snapshot also includes the latest
conﬁguration in the log as of last included index. Once a
server completes writing a snapshot, it may delete all log
entries up through the last included index, as well as any
prior snapshot.
Although servers normally take snapshots indepen-
dently, the leader must occasionally send snapshots to
followers that lag behind. This happens when the leader
has already discarded the next log entry that it needs to
send to a follower. Fortunately, this situation is unlikely
in normal operation: a follower that has kept up with the
Invoked by leader to send chunks of a snapshot to a follower.
Leaders always send chunks in order.
Arguments:
term
leader’s term
leaderId
so follower can redirect clients
lastIncludedIndex the snapshot replaces all entries up through
and including this index
lastIncludedTerm
term of lastIncludedIndex
offset
byte offset where chunk is positioned in the
snapshot file
data[]
raw bytes of the snapshot chunk, starting at
offset
done
true if this is the last chunk
Results:
term
currentTerm, for leader to update itself
Receiver implementation:
1.
Reply immediately if term < currentTerm
2.
Create new snapshot file if first chunk (offset is 0)
3.
Write data into snapshot file at given offset
4.
Reply and wait for more data chunks if done is false
5.
Save snapshot file, discard any existing or partial snapshot
with a smaller index
6.
If existing log entry has same index and term as snapshot’s
last included entry, retain log entries following it and reply
7.
Discard the entire log
8.
Reset state machine using snapshot contents (and load
snapshot’s cluster configuration)
InstallSnapshot RPC
Figure 13: A summary of the InstallSnapshot RPC. Snap-
shots are split into chunks for transmission; this gives the fol-
lower a sign of life with each chunk, so it can reset its election
timer.
leader would already have this entry. However, an excep-
tionally slow follower or a new server joining the cluster
(Section 6) would not. The way to bring such a follower
up-to-date is for the leader to send it a snapshot over the
network.
The leader uses a new RPC called InstallSnapshot to
send snapshots to followers that are too far behind; see
Figure 13. When a follower receives a snapshot with this
RPC, it must decide what to do with its existing log en-
tries. Usually the snapshot will contain new information
not already in the recipient’s log. In this case, the follower
discards its entire log; it is all superseded by the snapshot
and may possibly have uncommitted entries that conﬂict
with the snapshot. If instead the follower receives a snap-
shot that describes a preﬁx of its log (due to retransmis-
sion or by mistake), then log entries covered by the snap-
shot are deleted but entries following the snapshot are still
valid and must be retained.
This snapshotting approach departs from Raft’s strong
leader principle, since followers can take snapshots with-
out the knowledge of the leader. However, we think this
departure is justiﬁed. While having a leader helps avoid
conﬂicting decisions in reaching consensus, consensus
has already been reached when snapshotting, so no de-
cisions conﬂict. Data still only ﬂows from leaders to fol-
12

--- PDF page 13 ---
lowers, just followers can now reorganize their data.
We considered an alternative leader-based approach in
which only the leader would create a snapshot, then it
would send this snapshot to each of its followers. How-
ever, this has two disadvantages. First, sending the snap-
shot to each follower would waste network bandwidth and
slow the snapshotting process. Each follower already has
the information needed to produce its own snapshots, and
it is typically much cheaper for a server to produce a snap-
shot from its local state than it is to send and receive one
over the network. Second, the leader’s implementation
would be more complex. For example, the leader would
need to send snapshots to followers in parallel with repli-
cating new log entries to them, so as not to block new
client requests.
There are two more issues that impact snapshotting per-
formance. First, servers must decide when to snapshot. If
a server snapshots too often, it wastes disk bandwidth and
energy; if it snapshots too infrequently, it risks exhaust-
ing its storage capacity, and it increases the time required
to replay the log during restarts. One simple strategy is
to take a snapshot when the log reaches a ﬁxed size in
bytes. If this size is set to be signiﬁcantly larger than the
expected size of a snapshot, then the disk bandwidth over-
head for snapshotting will be small.
The second performance issue is that writing a snap-
shot can take a signiﬁcant amount of time, and we do
not want this to delay normal operations. The solution is
to use copy-on-write techniques so that new updates can
be accepted without impacting the snapshot being writ-
ten. For example, state machines built with functional data
structures naturally support this. Alternatively, the operat-
ing system’s copy-on-write support (e.g., fork on Linux)
can be used to create an in-memory snapshot of the entire
state machine (our implementation uses this approach).
8
Client interaction
This section describes how clients interact with Raft,
including how clients ﬁnd the cluster leader and how Raft
supports linearizable semantics [10]. These issues apply
to all consensus-based systems, and Raft’s solutions are
similar to other systems.
Clients of Raft send all of their requests to the leader.
When a client ﬁrst starts up, it connects to a randomly-
chosen server. If the client’s ﬁrst choice is not the leader,
that server will reject the client’s request and supply in-
formation about the most recent leader it has heard from
(AppendEntries requests include the network address of
the leader). If the leader crashes, client requests will time
out; clients then try again with randomly-chosen servers.
Our goal for Raft is to implement linearizable seman-
tics (each operation appears to execute instantaneously,
exactly once, at some point between its invocation and
its response). However, as described so far Raft can exe-
cute a command multiple times: for example, if the leader
crashes after committing the log entry but before respond-
ing to the client, the client will retry the command with a
new leader, causing it to be executed a second time. The
solution is for clients to assign unique serial numbers to
every command. Then, the state machine tracks the latest
serial number processed for each client, along with the as-
sociated response. If it receives a command whose serial
number has already been executed, it responds immedi-
ately without re-executing the request.
Read-only operations can be handled without writing
anything into the log. However, with no additional mea-
sures, this would run the risk of returning stale data, since
the leader responding to the request might have been su-
perseded by a newer leader of which it is unaware. Lin-
earizable reads must not return stale data, and Raft needs
two extra precautions to guarantee this without using the
log. First, a leader must have the latest information on
which entries are committed. The Leader Completeness
Property guarantees that a leader has all committed en-
tries, but at the start of its term, it may not know which
those are. To ﬁnd out, it needs to commit an entry from
its term. Raft handles this by having each leader com-
mit a blank no-op entry into the log at the start of its
term. Second, a leader must check whether it has been de-
posed before processing a read-only request (its informa-
tion may be stale if a more recent leader has been elected).
Raft handles this by having the leader exchange heart-
beat messages with a majority of the cluster before re-
sponding to read-only requests. Alternatively, the leader
could rely on the heartbeat mechanism to provide a form
of lease [9], but this would rely on timing for safety (it
assumes bounded clock skew).
9
Implementation and evaluation
We have implemented Raft as part of a replicated
state machine that stores conﬁguration information for
RAMCloud [33] and assists in failover of the RAMCloud
coordinator. The Raft implementation contains roughly
2000 lines of C++ code, not including tests, comments, or
blank lines. The source code is freely available [23]. There
are also about 25 independent third-party open source im-
plementations [34] of Raft in various stages of develop-
ment, based on drafts of this paper. Also, various compa-
nies are deploying Raft-based systems [34].
The remainder of this section evaluates Raft using three
criteria: understandability, correctness, and performance.
9.1
Understandability
To measure Raft’s understandability relative to Paxos,
we conducted an experimental study using upper-level un-
dergraduate and graduate students in an Advanced Oper-
ating Systems course at Stanford University and a Dis-
tributed Computing course at U.C. Berkeley. We recorded
a video lecture of Raft and another of Paxos, and created
corresponding quizzes. The Raft lecture covered the con-
tent of this paper except for log compaction; the Paxos
13

--- PDF page 14 ---
0
 10
 20
 30
 40
 50
 60
 0
 10
 20
 30
 40
 50
 60
Raft grade
Paxos grade
Raft then Paxos
Paxos then Raft
Figure 14: A scatter plot comparing 43 participants’ perfor-
mance on the Raft and Paxos quizzes. Points above the diag-
onal (33) represent participants who scored higher for Raft.
lecture covered enough material to create an equivalent
replicated state machine, including single-decree Paxos,
multi-decree Paxos, reconﬁguration, and a few optimiza-
tions needed in practice (such as leader election). The
quizzes tested basic understanding of the algorithms and
also required students to reason about corner cases. Each
student watched one video, took the corresponding quiz,
watched the second video, and took the second quiz.
About half of the participants did the Paxos portion ﬁrst
and the other half did the Raft portion ﬁrst in order to
account for both individual differences in performance
and experience gained from the ﬁrst portion of the study.
We compared participants’ scores on each quiz to deter-
mine whether participants showed a better understanding
of Raft.
We tried to make the comparison between Paxos and
Raft as fair as possible. The experiment favored Paxos in
two ways: 15 of the 43 participants reported having some
prior experience with Paxos, and the Paxos video is 14%
longer than the Raft video. As summarized in Table 1, we
have taken steps to mitigate potential sources of bias. All
of our materials are available for review [28, 31].
On average, participants scored 4.9 points higher on the
Raft quiz than on the Paxos quiz (out of a possible 60
points, the mean Raft score was 25.7 and the mean Paxos
score was 20.8); Figure 14 shows their individual scores.
A paired t-test states that, with 95% conﬁdence, the true
distribution of Raft scores has a mean at least 2.5 points
larger than the true distribution of Paxos scores.
We also created a linear regression model that predicts
a new student’s quiz scores based on three factors: which
quiz they took, their degree of prior Paxos experience, and
 0
 5
 10
 15
 20
implement
explain
number of participants
Paxos much easier
Paxos somewhat easier
Roughly equal
Raft somewhat easier
Raft much easier
Figure 15: Using a 5-point scale, participants were asked
(left) which algorithm they felt would be easier to implement
in a functioning, correct, and efﬁcient system, and (right)
which would be easier to explain to a CS graduate student.
the order in which they learned the algorithms. The model
predicts that the choice of quiz produces a 12.5-point dif-
ference in favor of Raft. This is signiﬁcantly higher than
the observed difference of 4.9 points, because many of the
actual students had prior Paxos experience, which helped
Paxos considerably, whereas it helped Raft slightly less.
Curiously, the model also predicts scores 6.3 points lower
on Raft for people that have already taken the Paxos quiz;
although we don’t know why, this does appear to be sta-
tistically signiﬁcant.
We also surveyed participants after their quizzes to see
which algorithm they felt would be easier to implement
or explain; these results are shown in Figure 15. An over-
whelming majority of participants reported Raft would be
easier to implement and explain (33 of 41 for each ques-
tion). However, these self-reported feelings may be less
reliable than participants’ quiz scores, and participants
may have been biased by knowledge of our hypothesis
that Raft is easier to understand.
A detailed discussion of the Raft user study is available
at [31].
9.2
Correctness
We have developed a formal speciﬁcation and a proof
of safety for the consensus mechanism described in Sec-
tion 5. The formal speciﬁcation [31] makes the informa-
tion summarized in Figure 2 completely precise using the
TLA+ speciﬁcation language [17]. It is about 400 lines
long and serves as the subject of the proof. It is also use-
ful on its own for anyone implementing Raft. We have
mechanically proven the Log Completeness Property us-
ing the TLA proof system [7]. However, this proof relies
on invariants that have not been mechanically checked
(for example, we have not proven the type safety of the
speciﬁcation). Furthermore, we have written an informal
proof [31] of the State Machine Safety property which
is complete (it relies on the speciﬁcation alone) and rela-
Concern
Steps taken to mitigate bias
Materials for review [28, 31]
Equal lecture quality
Same lecturer for both. Paxos lecture based on and improved from exist-
ing materials used in several universities. Paxos lecture is 14% longer.
videos
Equal quiz difﬁculty
Questions grouped in difﬁculty and paired across exams.
quizzes
Fair grading
Used rubric. Graded in random order, alternating between quizzes.
rubric
Table 1: Concerns of possible bias against Paxos in the study, steps taken to counter each, and additional materials available.
14

--- PDF page 15 ---
0%
20%
40%
60%
80%
100%
 100
 1000
 10000
 100000
cumulative percent
150-150ms
150-151ms
150-155ms
150-175ms
150-200ms
150-300ms
0%
20%
40%
60%
80%
100%
 0
 100
 200
 300
 400
 500
 600
cumulative percent
time without leader (ms)
12-24ms
25-50ms
50-100ms
100-200ms
150-300ms
Figure 16: The time to detect and replace a crashed leader.
The top graph varies the amount of randomness in election
timeouts, and the bottom graph scales the minimum election
timeout. Each line represents 1000 trials (except for 100 tri-
als for “150–150ms”) and corresponds to a particular choice
of election timeouts; for example, “150–155ms” means that
election timeouts were chosen randomly and uniformly be-
tween 150ms and 155ms. The measurements were taken on a
cluster of ﬁve servers with a broadcast time of roughly 15ms.
Results for a cluster of nine servers are similar.
tively precise (it is about 3500 words long).
9.3
Performance
Raft’s performance is similar to other consensus algo-
rithms such as Paxos. The most important case for per-
formance is when an established leader is replicating new
log entries. Raft achieves this using the minimal number
of messages (a single round-trip from the leader to half the
cluster). It is also possible to further improve Raft’s per-
formance. For example, it easily supports batching and
pipelining requests for higher throughput and lower la-
tency. Various optimizations have been proposed in the
literature for other algorithms; many of these could be ap-
plied to Raft, but we leave this to future work.
We used our Raft implementation to measure the per-
formance of Raft’s leader election algorithm and answer
two questions. First, does the election process converge
quickly? Second, what is the minimum downtime that can
be achieved after leader crashes?
To measure leader election, we repeatedly crashed the
leader of a cluster of ﬁve servers and timed how long it
took to detect the crash and elect a new leader (see Fig-
ure 16). To generate a worst-case scenario, the servers in
each trial had different log lengths, so some candidates
were not eligible to become leader. Furthermore, to en-
courage split votes, our test script triggered a synchro-
nized broadcast of heartbeat RPCs from the leader before
terminating its process (this approximates the behavior
of the leader replicating a new log entry prior to crash-
ing). The leader was crashed uniformly randomly within
its heartbeat interval, which was half of the minimum
election timeout for all tests. Thus, the smallest possible
downtime was about half of the minimum election time-
out.
The top graph in Figure 16 shows that a small amount
of randomization in the election timeout is enough to
avoid split votes in elections. In the absence of random-
ness, leader election consistently took longer than 10 sec-
onds in our tests due to many split votes. Adding just 5ms
of randomness helps signiﬁcantly, resulting in a median
downtime of 287ms. Using more randomness improves
worst-case behavior: with 50ms of randomness the worst-
case completion time (over 1000 trials) was 513ms.
The bottom graph in Figure 16 shows that downtime
can be reduced by reducing the election timeout. With
an election timeout of 12–24ms, it takes only 35ms on
average to elect a leader (the longest trial took 152ms).
However, lowering the timeouts beyond this point violates
Raft’s timing requirement: leaders have difﬁculty broad-
casting heartbeats before other servers start new elections.
This can cause unnecessary leader changes and lower
overall system availability. We recommend using a con-
servative election timeout such as 150–300ms; such time-
outs are unlikely to cause unnecessary leader changes and
will still provide good availability.
10
Related work
There have been numerous publications related to con-
sensus algorithms, many of which fall into one of the fol-
lowing categories:
• Lamport’s original description of Paxos [15], and at-
tempts to explain it more clearly [16, 20, 21].
• Elaborations of Paxos, which ﬁll in missing details
and modify the algorithm to provide a better founda-
tion for implementation [26, 39, 13].
• Systems that implement consensus algorithms, such
as Chubby [2, 4], ZooKeeper [11, 12], and Span-
ner [6]. The algorithms for Chubby and Spanner
have not been published in detail, though both claim
to be based on Paxos. ZooKeeper’s algorithm has
been published in more detail, but it is quite different
from Paxos.
• Performance optimizations that can be applied to
Paxos [18, 19, 3, 25, 1, 27].
• Oki and Liskov’s Viewstamped Replication (VR), an
alternative approach to consensus developed around
the same time as Paxos. The original description [29]
was intertwined with a protocol for distributed trans-
actions, but the core consensus protocol has been
separated in a recent update [22]. VR uses a leader-
based approach with many similarities to Raft.
The greatest difference between Raft and Paxos is
Raft’s strong leadership: Raft uses leader election as an
essential part of the consensus protocol, and it concen-
15

--- PDF page 16 ---
trates as much functionality as possible in the leader. This
approach results in a simpler algorithm that is easier to
understand. For example, in Paxos, leader election is or-
thogonal to the basic consensus protocol: it serves only as
a performance optimization and is not required for achiev-
ing consensus. However, this results in additional mecha-
nism: Paxos includes both a two-phase protocol for basic
consensus and a separate mechanism for leader election.
In contrast, Raft incorporates leader election directly into
the consensus algorithm and uses it as the ﬁrst of the two
phases of consensus. This results in less mechanism than
in Paxos.
Like Raft, VR and ZooKeeper are leader-based and
therefore share many of Raft’s advantages over Paxos.
However, Raft has less mechanism that VR or ZooKeeper
because it minimizes the functionality in non-leaders. For
example, log entries in Raft ﬂow in only one direction:
outward from the leader in AppendEntries RPCs. In VR
log entries ﬂow in both directions (leaders can receive
log entries during the election process); this results in
additional mechanism and complexity. The published de-
scription of ZooKeeper also transfers log entries both to
and from the leader, but the implementation is apparently
more like Raft [35].
Raft has fewer message types than any other algo-
rithm for consensus-based log replication that we are
aware of. For example, we counted the message types VR
and ZooKeeper use for basic consensus and membership
changes (excluding log compaction and client interaction,
as these are nearly independent of the algorithms). VR
and ZooKeeper each deﬁne 10 different message types,
while Raft has only 4 message types (two RPC requests
and their responses). Raft’s messages are a bit more dense
than the other algorithms’, but they are simpler collec-
tively. In addition, VR and ZooKeeper are described in
terms of transmitting entire logs during leader changes;
additional message types will be required to optimize
these mechanisms so that they are practical.
Raft’s strong leadership approach simpliﬁes the algo-
rithm, but it precludes some performance optimizations.
For example, Egalitarian Paxos (EPaxos) can achieve
higher performance under some conditions with a lead-
erless approach [27]. EPaxos exploits commutativity in
state machine commands. Any server can commit a com-
mand with just one round of communication as long as
other commands that are proposed concurrently commute
with it. However, if commands that are proposed con-
currently do not commute with each other, EPaxos re-
quires an additional round of communication. Because
any server may commit commands, EPaxos balances load
well between servers and is able to achieve lower latency
than Raft in WAN settings. However, it adds signiﬁcant
complexity to Paxos.
Several different approaches for cluster member-
ship changes have been proposed or implemented in
other work, including Lamport’s original proposal [15],
VR [22], and SMART [24]. We chose the joint consensus
approach for Raft because it leverages the rest of the con-
sensus protocol, so that very little additional mechanism
is required for membership changes. Lamport’s α-based
approach was not an option for Raft because it assumes
consensus can be reached without a leader. In comparison
to VR and SMART, Raft’s reconﬁguration algorithm has
the advantage that membership changes can occur with-
out limiting the processing of normal requests; in con-
trast, VR stops all normal processing during conﬁgura-
tion changes, and SMART imposes an α-like limit on the
number of outstanding requests. Raft’s approach also adds
less mechanism than either VR or SMART.
11
Conclusion
Algorithms are often designed with correctness, efﬁ-
ciency, and/or conciseness as the primary goals. Although
these are all worthy goals, we believe that understandabil-
ity is just as important. None of the other goals can be
achieved until developers render the algorithm into a prac-
tical implementation, which will inevitably deviate from
and expand upon the published form. Unless developers
have a deep understanding of the algorithm and can cre-
ate intuitions about it, it will be difﬁcult for them to retain
its desirable properties in their implementation.
In this paper we addressed the issue of distributed con-
sensus, where a widely accepted but impenetrable algo-
rithm, Paxos, has challenged students and developers for
many years. We developed a new algorithm, Raft, which
we have shown to be more understandable than Paxos.
We also believe that Raft provides a better foundation
for system building. Using understandability as the pri-
mary design goal changed the way we approached the de-
sign of Raft; as the design progressed we found ourselves
reusing a few techniques repeatedly, such as decomposing
the problem and simplifying the state space. These tech-
niques not only improved the understandability of Raft
but also made it easier to convince ourselves of its cor-
rectness.
12
Acknowledgments
The user study would not have been possible with-
out the support of Ali Ghodsi, David Mazi`eres, and the
students of CS 294-91 at Berkeley and CS 240 at Stan-
ford. Scott Klemmer helped us design the user study,
and Nelson Ray advised us on statistical analysis. The
Paxos slides for the user study borrowed heavily from
a slide deck originally created by Lorenzo Alvisi. Spe-
cial thanks go to David Mazi`eres and Ezra Hoch for
ﬁnding subtle bugs in Raft. Many people provided help-
ful feedback on the paper and user study materials,
including Ed Bugnion, Michael Chan, Hugues Evrard,
16

--- PDF page 17 ---
Daniel Gifﬁn, Arjun Gopalan, Jon Howell, Vimalkumar
Jeyakumar, Ankita Kejriwal, Aleksandar Kracun, Amit
Levy, Joel Martin, Satoshi Matsushita, Oleg Pesok, David
Ramos, Robbert van Renesse, Mendel Rosenblum, Nico-
las Schiper, Deian Stefan, Andrew Stone, Ryan Stutsman,
David Terei, Stephen Yang, Matei Zaharia, 24 anony-
mous conference reviewers (with duplicates), and espe-
cially our shepherd Eddie Kohler. Werner Vogels tweeted
a link to an earlier draft, which gave Raft signiﬁcant ex-
posure. This work was supported by the Gigascale Sys-
tems Research Center and the Multiscale Systems Cen-
ter, two of six research centers funded under the Fo-
cus Center Research Program, a Semiconductor Research
Corporation program, by STARnet, a Semiconductor Re-
search Corporation program sponsored by MARCO and
DARPA, by the National Science Foundation under Grant
No. 0963859, and by grants from Facebook, Google, Mel-
lanox, NEC, NetApp, SAP, and Samsung. Diego Ongaro
is supported by The Junglee Corporation Stanford Gradu-
ate Fellowship.
References
[1] BOLOSKY, W. J., BRADSHAW, D., HAAGENS, R. B.,
KUSTERS, N. P., AND LI, P.
Paxos replicated state
machines as the basis of a high-performance data store.
In Proc. NSDI’11, USENIX Conference on Networked
Systems Design and Implementation (2011), USENIX,
pp. 141–154.
[2] BURROWS, M.
The Chubby lock service for loosely-
coupled distributed systems. In Proc. OSDI’06, Sympo-
sium on Operating Systems Design and Implementation
(2006), USENIX, pp. 335–350.
[3] CAMARGOS, L. J., SCHMIDT, R. M., AND PEDONE, F.
Multicoordinated Paxos. In Proc. PODC’07, ACM Sym-
posium on Principles of Distributed Computing (2007),
ACM, pp. 316–317.
[4] CHANDRA, T. D., GRIESEMER, R., AND REDSTONE, J.
Paxos made live: an engineering perspective.
In Proc.
PODC’07, ACM Symposium on Principles of Distributed
Computing (2007), ACM, pp. 398–407.
[5] CHANG, F., DEAN, J., GHEMAWAT, S., HSIEH, W. C.,
WALLACH, D. A., BURROWS, M., CHANDRA, T.,
FIKES, A., AND GRUBER, R. E. Bigtable: a distributed
storage system for structured data.
In Proc. OSDI’06,
USENIX Symposium on Operating Systems Design and
Implementation (2006), USENIX, pp. 205–218.
[6] CORBETT, J. C., DEAN, J., EPSTEIN, M., FIKES, A.,
FROST, C., FURMAN, J. J., GHEMAWAT, S., GUBAREV,
A., HEISER, C., HOCHSCHILD, P., HSIEH, W., KAN-
THAK, S., KOGAN, E., LI, H., LLOYD, A., MELNIK,
S., MWAURA, D., NAGLE, D., QUINLAN, S., RAO, R.,
ROLIG, L., SAITO, Y., SZYMANIAK, M., TAYLOR, C.,
WANG, R., AND WOODFORD, D.
Spanner: Google’s
globally-distributed database. In Proc. OSDI’12, USENIX
Conference on Operating Systems Design and Implemen-
tation (2012), USENIX, pp. 251–264.
[7] COUSINEAU, D., DOLIGEZ, D., LAMPORT, L., MERZ,
S., RICKETTS, D., AND VANZETTO, H. TLA+ proofs.
In Proc. FM’12, Symposium on Formal Methods (2012),
D. Giannakopoulou and D. M´ery, Eds., vol. 7436 of Lec-
ture Notes in Computer Science, Springer, pp. 147–154.
[8] GHEMAWAT, S., GOBIOFF, H., AND LEUNG, S.-T. The
Google ﬁle system. In Proc. SOSP’03, ACM Symposium
on Operating Systems Principles (2003), ACM, pp. 29–43.
[9] GRAY, C., AND CHERITON, D. Leases: An efﬁcient fault-
tolerant mechanism for distributed ﬁle cache consistency.
In Proceedings of the 12th ACM Ssymposium on Operating
Systems Principles (1989), pp. 202–210.
[10] HERLIHY, M. P., AND WING, J. M. Linearizability: a
correctness condition for concurrent objects. ACM Trans-
actions on Programming Languages and Systems 12 (July
1990), 463–492.
[11] HUNT, P., KONAR, M., JUNQUEIRA, F. P., AND REED,
B. ZooKeeper: wait-free coordination for internet-scale
systems. In Proc ATC’10, USENIX Annual Technical Con-
ference (2010), USENIX, pp. 145–158.
[12] JUNQUEIRA, F. P., REED, B. C., AND SERAFINI, M.
Zab: High-performance broadcast for primary-backup sys-
tems. In Proc. DSN’11, IEEE/IFIP Int’l Conf. on Depend-
able Systems & Networks (2011), IEEE Computer Society,
pp. 245–256.
[13] KIRSCH, J., AND AMIR, Y. Paxos for system builders.
Tech. Rep. CNDS-2008-2, Johns Hopkins University,
2008.
[14] LAMPORT, L. Time, clocks, and the ordering of events in
a distributed system. Commununications of the ACM 21, 7
(July 1978), 558–565.
[15] LAMPORT, L. The part-time parliament. ACM Transac-
tions on Computer Systems 16, 2 (May 1998), 133–169.
[16] LAMPORT, L. Paxos made simple. ACM SIGACT News
32, 4 (Dec. 2001), 18–25.
[17] LAMPORT, L. Specifying Systems, The TLA+ Language
and Tools for Hardware and Software Engineers. Addison-
Wesley, 2002.
[18] LAMPORT, L. Generalized consensus and Paxos. Tech.
Rep. MSR-TR-2005-33, Microsoft Research, 2005.
[19] LAMPORT, L. Fast paxos. Distributed Computing 19, 2
(2006), 79–103.
[20] LAMPSON, B. W. How to build a highly available system
using consensus. In Distributed Algorithms, O. Baboaglu
and K. Marzullo, Eds. Springer-Verlag, 1996, pp. 1–17.
[21] LAMPSON, B. W.
The ABCD’s of Paxos.
In Proc.
PODC’01, ACM Symposium on Principles of Distributed
Computing (2001), ACM, pp. 13–13.
[22] LISKOV, B., AND COWLING, J.
Viewstamped replica-
tion revisited. Tech. Rep. MIT-CSAIL-TR-2012-021, MIT,
July 2012.
[23] LogCabin
source
code.
http://github.com/
logcabin/logcabin.
17

--- PDF page 18 ---
[24] LORCH, J. R., ADYA, A., BOLOSKY, W. J., CHAIKEN,
R., DOUCEUR, J. R., AND HOWELL, J.
The SMART
way to migrate replicated stateful services. In Proc. Eu-
roSys’06, ACM SIGOPS/EuroSys European Conference on
Computer Systems (2006), ACM, pp. 103–115.
[25] MAO, Y., JUNQUEIRA, F. P., AND MARZULLO, K.
Mencius: building efﬁcient replicated state machines for
WANs.
In Proc. OSDI’08, USENIX Conference on
Operating Systems Design and Implementation (2008),
USENIX, pp. 369–384.
[26] MAZI`ERES, D.
Paxos made practical.
http:
//www.scs.stanford.edu/˜dm/home/
papers/paxos.pdf, Jan. 2007.
[27] MORARU, I., ANDERSEN, D. G., AND KAMINSKY, M.
There is more consensus in egalitarian parliaments.
In
Proc. SOSP’13, ACM Symposium on Operating System
Principles (2013), ACM.
[28] Raft user study.
http://ramcloud.stanford.
edu/˜ongaro/userstudy/.
[29] OKI, B. M.,
AND LISKOV, B. H.
Viewstamped
replication: A new primary copy method to support
highly-available distributed systems. In Proc. PODC’88,
ACM Symposium on Principles of Distributed Computing
(1988), ACM, pp. 8–17.
[30] O’NEIL, P., CHENG, E., GAWLICK, D., AND ONEIL, E.
The log-structured merge-tree (LSM-tree). Acta Informat-
ica 33, 4 (1996), 351–385.
[31] ONGARO, D. Consensus: Bridging Theory and Practice.
PhD thesis, Stanford University, 2014 (work in progress).
http://ramcloud.stanford.edu/˜ongaro/
thesis.pdf.
[32] ONGARO, D., AND OUSTERHOUT, J.
In search of an
understandable consensus algorithm.
In Proc ATC’14,
USENIX Annual Technical Conference (2014), USENIX.
[33] OUSTERHOUT,
J.,
AGRAWAL,
P.,
ERICKSON,
D.,
KOZYRAKIS, C., LEVERICH, J., MAZI`ERES, D., MI-
TRA, S., NARAYANAN, A., ONGARO, D., PARULKAR,
G., ROSENBLUM, M., RUMBLE, S. M., STRATMANN,
E., AND STUTSMAN, R. The case for RAMCloud. Com-
munications of the ACM 54 (July 2011), 121–130.
[34] Raft consensus algorithm website.
http://raftconsensus.github.io.
[35] REED, B. Personal communications, May 17, 2013.
[36] ROSENBLUM, M., AND OUSTERHOUT, J. K. The design
and implementation of a log-structured ﬁle system. ACM
Trans. Comput. Syst. 10 (February 1992), 26–52.
[37] SCHNEIDER, F. B. Implementing fault-tolerant services
using the state machine approach: a tutorial. ACM Com-
puting Surveys 22, 4 (Dec. 1990), 299–319.
[38] SHVACHKO,
K.,
KUANG,
H.,
RADIA,
S.,
AND
CHANSLER, R.
The Hadoop distributed ﬁle system.
In Proc. MSST’10, Symposium on Mass Storage Sys-
tems and Technologies (2010), IEEE Computer Society,
pp. 1–10.
[39] VAN RENESSE, R.
Paxos made moderately complex.
Tech. rep., Cornell University, 2012.
18

### faq: FAQ

- URL: http://nil.csail.mit.edu/6.824/2021/papers/raft2-faq.txt
- Local path: official-materials/faqs/raft2-faq.txt

#### Archived Content

Raft (2) FAQ

Q: What are some uses of Raft besides GFS master replication?

A: You could (and will) build a fault-tolerant key/value database using Raft.

You could make the MapReduce master fault-tolerant with Raft.

You could build a fault-tolerant locking service.


Q: When raft receives a read request does it still commit a no-op?

A: Section 8 mentions two different approaches. The leader could send out a
heartbeat first; or there could be a convention that the leader can't
change for a known period of time after each heartbeat (the lease).
Real systems usually use a lease, since it requires less
communication.

Section 8 says the leader sends out a no-op only at the very beginning
of its term.

Q: The paper states that no log writes are required on a read, but
then immediately goes on to introduce committing a no-op as a
technique to get the committed. Is this a contradiction or are no-ops
not considered log 'writes'?

A: The no-op only happens at the start of the term, not for each read.


Q: I find the line about the leader needing to commit a no-op entry in
order to know which entries are committed pretty confusing. Why does
it need to do this?

A: The problem situation is shown in Figure 8, where if S1 becomes
leader after (b), it cannot know if its last log entry (2) is
committed or not. The situation in which the last log entry will turn
out not to be committed is if S1 immediately fails, and S5 is the next
leader; in that case S5 will force all peers (including S1) to have
logs identical to S5's log, which does not include entry 2.

But suppose S1 manages to commit a new entry during its term (term 4).
If S5 sees the new entry, S5 will erase 3 from its log and accept 2 in
its place. If S5 does not see the new entry, S5 cannot be the next
leader if S1 fails, because it will fail the Election Restriction.
Either way, once S1 has committed a new entry for its term, it can
correctly conclude that every preceding entry in its log is committed.

The no-op text at the end of Section 8 is talking about an optimization
in which the leader executes and answers read-only commands (e.g.
get("k1")) without committing those commands in the log. For example,
for get("k1"), the leader just looks up "k1" in its key/value table and
sends the result back to the client. If the leader has just started, it
may have at the end of its log a put("k1", "v99"). Should the leader
send "v99" back to the client, or the value in the leader's key/value
table? At first, the leader doesn't know whether that v99 log entry is
committed (and must be returned to the client) or not committed (and
must not be sent back). So (if you are using this optimization) a new
Raft leader first tries to commit a no-op to the log; if the commit
succeeds (i.e. the leader doesn't crash), then the leader knows
everything before that point is committed.

Q: How does using the heartbeat mechanism to provide leases (for
read-only) operations work, and why does this require timing for
safety (e.g. bounded clock skew)?

A: I don't know exactly what the authors had in mind. Perhaps every
AppendEntries RPC the leader sends out says or implies that the no other
leader is allowed to be elected for the next 100 milliseconds. If the
leader gets positive responses from a majority, then the leader can
serve read-only requests for the next 100 milliseconds without further
communication with the followers.

This requires the servers to have the same definition of what 100
milliseconds means, i.e. they must have clocks that tick at the close to
the same rate.


Q: What exactly do the C_old and C_new variables in Section 6 (and
Figure 11) represent? Are they the leader in each configuration?

A: They are the set of servers in the old/new configuration.

The paper doesn't provide details. I believe it's the identities
(network names or addresses) of the servers.

Q: When transitioning from cluster C_old to cluster C_new, how can we
create a hybrid cluster C_{old,new}? I don't really understand what
that means. Isn't it following either the network configuration of
C_old or of C_new? What if the two networks disagreed on a connection?

A: During the period of joint consensus (while Cold,new is active), the
leader is required to get a majority from both the servers in Cold and
the servers in Cnew.

There can't really be disagreement, because after Cold,new is committed
into the logs of both Cold and Cnew (i.e. after the period of joint
consensus has started), any new leader in either Cold or Cnew is
guaranteed to see the log entry for Cold,Cnew.


Q: I'm confused about Figure 11 in the paper. I'm unsure about how
exactly the transition from 'C_old' to 'C_old,new' to 'C_new' goes.
Why is there the issue of the cluster leader not being a part of the
new configuration, where the leader steps down once it has committed
the 'C_new' log entry? (The second issue mentioned in Section 6)

A: Suppose C_old={S1,S2,S3} and C_new={S4,S5,S6}, and that S1 is the leader
at the start of the configuration change. At the end of the
configuration change, after S1 has committed C_new, S1 should not be
participating any more, since S1 isn't in C_new. One of S4, S5, or S6
should take over as leader.

Q: About cluster configuration: During the configuration change time, if
we have to stop receiving requests from the clients, then what's the
point of having this automated configuration step? Doesn't it suffice
to just 1) stop receiving requests 2) change the configurations 3)
restart the system and continue?

A: The challenge here is ensuring that the system is correct even if there
are failures during this process, and even if not all servers get the
"stop receiving requests" and "change the configuration" commands at the
same time. Any scheme has to cope with the possibility of a mix of
servers that have and have not seen or completed the configuration
change -- this is true even of a non-automated system. The paper's
protocol is one way to solve this problem.

Q: The last two paragraphs of section 6 discuss removed servers
interfering with the cluster by trying to get elected even though
they’ve been removed from the configuration.
Wouldn’t a simpler solution be to require servers to be
shut down when they leave the configuration? It seems that leaving the
cluster implies that a server can’t send or receive RPCs to
the rest of the cluster anymore, but the paper doesn’t
assume that. Why not? Why can’t you assume that the servers
will shut down right away?

A: I think the immediate problem is that the Section 6 protocol doesn't
commit Cnew to the old servers, it only commits Cnew to the servers in
Cnew. So the servers that are not in Cnew never learn when Cnew takes
over from Cold,new.

The paper does say this:

  When the new configuration has been committed under the rules of Cnew,
  the old configuration is irrelevant and servers not in the new
  configuration can be shut down.

So perhaps the problem only exists during the period of time between the
configuration change and when an administrator shuts down the old
servers. I don't know why they don't have a more automated scheme.


Q: How common is it to get a majority from both the old and new
configurations when doing things like elections and entry commitment,
if it's uncommon, how badly would this affect performance?

A: I imagine that in most cases there is no failure, and the leader gets
both majorities right away. Configuration change probably only takes a
few round trip times, i.e. a few dozen milliseconds, so the requirement
to get both majorities will slow the system down for only a small amount
of time. Configuration change is likely to be uncommon (perhaps every
few months); a few milliseconds of delay every few months doesn't seem
like a high price.

Q: And how important is the decision to have both majorities?

A: The requirement for both majorities is required for correctness, to
cover the possibility that the leader fails during the configuration
change.


Q: Just to be clear, the process of having new members join as non-voting
entities isn't to speed up the process of replicating the log, but
rather to influence the election process? How does this increase
availability? These servers that need to catch up are not going to be
available regardless, right?


A: The purpose of non-voting servers is to allow those servers to get a
complete copy of the leader's log without holding up new commits. The
point is to allow a subsequent configuration change to be quick. If the
new servers didn't already have nearly-complete logs, then the leader
wouldn't be able to commit Cold,new until they caught up; and no new
client commands can be executed between the time Cold,new is first sent
out and the time at which it is committed.


Q: If the cluster leader does not have the new configuration, why doesn't
it just remove itself from majority while committing C_new, and then
when done return to being leader? Is there a need for a new election
process?


A: Is this about the "second issue" in Section 6? The situation they
describe is one in which the leader isn't in the new configuration at
all. So after Cnew is committed, the leader shouldn't be participating
in Raft at all.


Q: How does the non-voting membership status work in the configuration change
portion of Raft. Does that server state only last during the changeover
(i.e. while c_new not committed) or do servers only get full voting privileges
after being fully "caught up"? If so, at what point are they considered
"caught up"?

A: The paper doesn't have much detail here. I imagine that the leader won't
start the configuration change until the servers to be added (the
non-voting members) are close to completely caught up. When the leader
sends out the Cold,new log entry in AppendEntries RPCs to those new
servers, the leader will bring them fully up to date (using the Figure 2
machinery). The leader won't be able to commit the Cold,new message
until a majority of those new servers are fully caught up. Once the
Cold,new message is committed, those new servers can vote.


Q: I don't disagree that having servers deny RequestVotes that are less than
the minimum election timeout from the last heartbeat is a good idea (it
helps prevent unnecessary elections in general), but why did they choose
that method specifically to prevent servers not in a configuration running
for election? It seems like it would make more sense to check if a given
server is in the current configuration. E.g., in the lab code we are using,
each server has the RPC addresses of all the servers (in the current
configuration?), and so should be able to check if a requestVote RPC came
from a valid (in-configuration) server, no?

Q: I agree that the paper's design seems a little awkward, and I don't know
why they designed it that way. Your idea seems like a reasonable
starting point. One complication is that there may be situations in
which a server in Cnew is leader during the joint consensus phase, but
at that time some servers in Cold may not know about the joint consensus
phase (i.e. they only know about Cold, not Cold,new); we would not want
the latter servers to ignore the legitimate leader.


Q: When exactly does joint consensus begin, and when does it end? Does joint
consensus begin at commit time of "C_{o,n}"?

A: Joint consensus is in progress when the current leader is aware of
Cold,new. If the leader doesn't manage to commit Cold,new, and crashes,
and the new leader doesn't have Cold,new in its log, then joint
consensus ends early. If a leader manages to commit Cold,new, then joint
consensus has not just started but will eventually complete, when a
leader commits Cnew.

Q: Can the configuration log entry be overwritten by a subsequent leader
(assuming that the log entry has not been committed)?

A: Yes, that is possible, if the original leader trying to send out Cold,new
crashes before it commits the Cold,new.


Q: How can the "C_{o,n}" log entry ever be committed? It seems like it must be
replicated to a majority of "old" servers (as well as the "new" servers), but
the append of "C_{o,n}" immediately transitions the old server to new, right?

A: The commit does not change the set of servers in Cold or Cnew. For example,
perhaps the original configuration contains servers S1, S2, S3; then Cold
is {S1,S2,S3}. Perhaps the desired configuration is S4, S5, S6; then
Cnew is {S4,S5,S6}. Once Cnew is committed to the log, the configuration
is Cnew={S4,S5,S6}; S1,S2, and S3 are no longer part of the configuration.


Q: When snapshots are created, is the data and state used the one for the
client application? If it's the client's data then is this something
that the client itself would need to support in addition to the
modifications mentioned in the raft paper?

A: Example: if you are building a key/value server that uses Raft for
replication, then there will be a key/value module in the server that
stores a table of keys and values. It is that table of keys and values
that is saved in the snapshot.


Q: The paper says that "if the follower receives a snapshot that
describves a prefix of its log, then log entries covered by the
snapshot are deleted but entries following the snapshot are retained".
This means that we could potentially be deleting operations on the
state machinne.

A: I don't think information will be lost. If the snapshot covers a prefix
of the log, that means the snapshot includes the effects of all the
operations in that prefix. So it's OK to discard that prefix.


Q: It seems that snapshots are useful when they are a lot smaller than
applying the sequence of updates (e.g., frequent updates to a few
keys). What happens when a snapshot is as big as the sum of its
updates (e.g., each update inserts a new unique key)? Are there any
cost savings from doing snapshots at all in this case?

A: If the snapshot is about as big as the log, then there may not be a lot
of value in having snapshots. On the other hand, perhaps the snapshot
organizes the data in a way that's easier to access than a log, e.g. in
a sorted table. Then it might be faster to re-start the service after a
crash+reboot from a snapshotted table than from the log (which you would
have to sort).

It's much more typical, however, for the log to be much bigger than the
state.

Q: Also wouldn't a InstallSnapshot incur heavy bandwidth costs?

A: Yes, if the state is large (as it would be for e.g. a database).
However, this is not an easy problem to solve. You'd probably want the
leader to keep enough of its log to cover all common cases of followers
lagging or being temporarily offline. You might also want a way to
transfer just the differences in server state, e.g. just the parts of
the database that have changed recently.


Q: Is there a concern that writing the snapshot can take longer than the
election timeout because of the amount of data that needs to be
appended to the log?

A: You're right that it's a potential problem for a large server. For
example if you're replicating a database with a gigabyte of data, and
your disk can only write at 100 megabytes per second, writing the
snapshot will take ten seconds. One possibility is to write the snapshot
in the background (i.e. arrange to not wait for the write, perhaps by
doing the write from a child process), and to make sure that snapshots
are created less often than once per ten seconds.


Q: Under what circumstances would a follower receive a snapshot that is a
prefix of its own log?

A: The network can deliver messages out of order, and the RPC handling
system can execute them out of order. So for example if the leader sends
a snapshot for log index 100, and then one for log index 110, but the
network delivers the second one first.

Q: Additionally, if the follower receives a snapshot that is a
prefix of its log, and then replaces the entries in its log up to that
point, the entries after that point are ones that the leader is not
aware of, right?

A: The follower might have log entries that are not in a received snapshot
if the network delays delivery of the snapshot, or if the leader has
sent out log entires but not yet committed them.

Q: Will those entries ever get committed?

A: They could get committed.


Q: How does the processing of InstallSnapshot RPC handle reordering, when the
check at step 6 references log entries that have been compacted? Specifically,
shouldn't Figure 13 include: 1.5: If lastIncludedIndex < commitIndex, return
immediately.  or alternatively 1.5: If there is already a snapshot and
lastIncludedIndex < currentSnapshot.lastIncludedIndex, return immediately.

A: I agree -- for Lab 3B the InstallSnapshot RPC handler must reject stale
snapshots. I don't know why Figure 13 doesn't include this test; perhaps
the authors' RPC system is better about order than ours. Or perhaps the
authors intend that we generalize step 6 in Figure 13 to cover this case.


Q: What happens when the leader sends me an InstallSnapshot command that
is for a prefix of my log, but I've already undergone log compaction
and my snapshot is ahead? Is it safe to assume that my snapshot that
is further forward subsumes the smaller snapshot?


A: Yes, it is correct for the recipient to ignore an InstallSnapshot if the
recipient is already ahead of that snapshot. This case can arise in Lab
3, for example if the RPC system delivers RPCs out of order.


Q: How do leaders decide which servers are lagging and need to be sent a
snapshot to install?

A: If a follower rejects an AppendEntries RPC for log index i1 due to rule
#2 or #3 (under AppendEntries RPC in Figure 2), and the leader has
discarded its log before i1, then the leader will send an
InstallSnapshot rather than backing up nextIndex[].


Q: In actual practical use of raft, how often are snapshots sent?

A: I have not seen an analysis of real-life Raft use. I imagine people
using Raft would tune it so that snapshots were rarely needed (e.g. by
having leaders keep lots of log entries with which to update lagging
followers).


Q: Is InstallSnapshot atomic? If a server crashes after partially
installing a snapshot, and the leader re-sends the InstallSnapshot
RPC, is this idempotent like RequestVote and AppendEntries RPCs?

A: The implementation of InstallSnapshot must be atomic.

It's harmless for the leader to re-send a snapshot.

Q: Why is an offset needed to index into the data[] of an InstallSNapshot
RPC, is there data not related to the snapshot? Or does it overlap
previous/future chunks of the same snapshot? Thanks!

A: The complete snapshot may be sent in multiple RPCs, each containing a
different part ("chunk") of the complete snapshot. The offset field
indicates where this RPC's data should go in the complete snapshot.

Q: How does a leader know when to send a snapshot to a follower?

A: When the matchIndex for the follower is smaller than the index for
the beginning of the leader's log.

Q: How does copy-on-write help with the performance issue of creating snapshots?

A: The basic idea is for the server to fork() when the service wants
to make a checkpoint, giving the child a complete copy of the
in-memory state. If fork() really copied all the memory, and the state
was large, this would be slow. But most operating systems don't copy
all the memory in fork(); instead they mark the pages as
"copy-on-write", and make them read-only in both parent and
child. Then the operating system will see a page fault if either tries
to write a page, and the operating system will only copy the page at
that point.  The net effect is usually that the child sees a copy of
its parent process' memory at the time of the fork(), but with
relatively little copying.


Q: What data compression schemes, such as VIZ, ZIP, Huffman encoding,
etc. are most efficient for Raft snapshotting?

A: It depends on what data the service stores. If it stores images, for
example, then maybe you'd want to compress them with JPEG.

If you are thinking that each snapshot probably shares a lot of content
with previous snapshots, then perhaps you'd want to use some kind of
tree structure which can share nodes across versions.


Q: Does adding an entry to the log count as an executed operation?

A: No. A server should only execute an operation in a log entry after the
leader has indicated that the log entry is committed. "Execute" means
handing the operation to the service that's using Raft. In Lab 3,
"execute" means that Raft gives the committed log entry to your
key/value software, which applies the Put(key,value) or Get(key) to its
table of key/value pairs.


Q: According to the paper, a server disregards RequestVoteRPCs when they
think a current leader exists, but then the moment they think a
current leader doesn't exist, I thought they try to start their own
election. So in what case would they actually cast a vote for another
server?

For the second question, I'm still confused: what does the paper mean
when it says a server should disregard a RequestVoteRPC when it thinks
a current leader exists at the end of Section 6? In what case would a
server think a current leader doesn't exist but hasn't started its own
election? Is it if the server thinks it hasn't yet gotten a heartbeat
from the server but before its election timeout?

A: Each server waits for a randomly chosen election timeout; if it hasn't heard
from the leader for that whole period, and no other server has started an
election, then the server starts an election. Whichever server's election timer
expires first is likely to get votes from most or all of the servers before any
other server's timer expires, and thus is likely to win the election.

Suppose the heartbeat interval is 10 milliseconds (ms). The leader sends
out heartbeats at times 10, 20, and 30.

Suppose server S1 doesn't hear the heartbeat at time 30. S1's election timer
goes off at time 35, and S1 sends out RequestVote RPCs.

Suppose server S2 does hear the heartbeat at time 30, so it knows the
server was alive at that time. S2 will set its election timer to go off
no sooner than time 40, since only a missing heartbeat indicates a
possibly dead server, and the next heartbeat won't come until time 40.
When S2 hears S1'a RequestVote at time 35, S2 can ignore the
RequestVote, because S2 knows that it heard a heartbeat less than one
heartbeat interval ago.


Q: I'm a little confused by the "how to roll back quickly" part of the
Lecture 6 notes (and the corresponding part of the paper):

  paper outlines a scheme towards end of Section 5.3:
  if follower rejects, includes this in reply:
    the term of the conflicting entry
    the index of the first entry for conflicting term
  if leader knows about the conflicting term:
    move nextIndex[i] back to its last entry for the conflicting term
  else:
    move nextIndex[i] back to follower's first index

I think according to the paper, the leader should move nextIndex[i] to
the index of the first entry for conflicting term. What does the
situation "if leader knows about the conflicting term" mean?

A: The paper's description of the algorithm is not complete, so we have to
invent the details for ourselves. The notes have the version I invented;
I don't know if it's what the authors had in mind.

The specific problem with the paper's "index of the first entry for the
conflicting term" is that the leader might no have entries at all for
the conflicting term. Thus my notes cover two cases -- if the server
knows about the conflicting term, and if it doesn't.


Q: What are the tradeoffs in network/ performance in decreasing nextIndex
by a factor of 2 each time at each mismatch? i.e. first by 1,2,4, 8
and so on

A: The leader will overshoot by up to a factor of two, and thus have to
send more entries than needed. Of course the Figure 2 approach is also
wasteful if one has to back up a lot. Best might be to implement
something more precise, for example the optimization outlined towards
the end of section 5.3.

Q: Why are read-only operations avoiding the log?

A: It is more efficient to avoid running read-only operations through
Raft and store them in the log.  Read-only operations are typically
more common than write operations, so this could save both time and
space.

Q: The paper says that before responding to read-only requests, the
leader exchanges heart-beats with a majority of the servers. How does
this fit into the existing Raft framework?

A: The leader sends AppendEntry RPCs (most likely empty) to all the
peers and replies after a majority of them respond.  This is more
efficient than running Raft because the operations are not stored in
the log, and the leader doesn't have to wait until the operation
appears on the applyCh, which serializes all operations.


Q: Unrelatedly - How does your experience teaching Raft and Paxos
correspond to section 9.1 of the paper? Do your experiences support
their findings?


A: I was pretty happy with the 6.824 Paxos labs from a few years ago.
I'm pretty happy with the current Raft labs too. The Raft labs are
more ambitious: unlike the Paxos labs, the Raft labs have a leader,
persistence, and snapshots. I don't think we have any light to shed on
the findings in Section 9.1; we didn't perform a side-by-side
experiment on the students, and our Raft labs are noticeably more
ambitious.


Q: What has been the impact of Raft, from the perspective of academic
researchers in the field? Is it considered significant, inspiring,
non-incremental work? Or is it more of "okay, this seems like a
natural progression, and is a bit easier to teach, so let's teach
this?"

A: The Raft paper does a better job than any paper I know of in explaining
modern replicated state machine techniques. I think it has inspired lots
of people to build their own replication implementations.


Q: The paper states that there are a fair amount of implementations of Raft out
in the wild. Have there been any improvement suggestions that would make sense
to include in a revised version of the algorithm?

A: Here's an example:

https://www.cl.cam.ac.uk/~ms705/pub/papers/2015-osr-raft.pdf

### homework: Question

- URL: http://nil.csail.mit.edu/6.824/2021/questions.html?q=q-raft2&lec=7
- Local path: official-materials/questions/07-q-raft2.html

#### Assigned Question

Could a received InstallSnapshot RPC cause the state machine to go backwards in time? That is, could step 8 in Figure 13 cause the state machine to be reset so that it reflects fewer executed operations? If yes, explain how this could happen. If no, explain why it can't happen.
