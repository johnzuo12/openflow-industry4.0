//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package openflow.apps;

import inet.applications.ITCPApp;


simple ClientApp like ITCPApp
{
    parameters:
        string localAddress = default(""); // may be left empty ("")
        int localPort = default(-1); // port number to listen on
        string connectAddress = default("");  // server address (may be symbolic)
        int connectPort = default(1000); // port number to connect to
        string dataTransferMode @enum("bytecount","object","bytestream") = default("bytecount");
        double startTime @unit(s) = default(0s); // time first session begins
        double stopTime @unit(s) = default(-1s);  // time of finishing sending, negative values mean forever
        volatile int numRequestsPerSession = default(1);  // number of requests sent per session
        volatile int requestLength @unit(B) = default(200B); // length of a request
        volatile int replyLength @unit(B) = default(1MiB); // length of a reply
        volatile double thinkTime @unit(s); // time gap between requests
        volatile double idleInterval @unit(s); // time gap between sessions
        volatile double reconnectInterval @unit(s) = default(30s);  // if connection breaks, waits this much before trying to reconnect
        @display("i=block/app");
        @signal[sentPk](type=cPacket);
        @signal[rcvdPk](type=cPacket);
        @signal[connect](type=long);  // 1 for open, -1 for close
        @statistic[rcvdPk](title="packets received"; source=rcvdPk; record=count,"sum(packetBytes)","vector(packetBytes)"; interpolationmode=none);
        @statistic[sentPk](title="packets sent"; source=sentPk; record=count,"sum(packetBytes)","vector(packetBytes)"; interpolationmode=none);
        @statistic[endToEndDelay](title="end-to-end delay"; source="messageAge(rcvdPk)"; unit=s; record=histogram,vector; interpolationmode=none);
        @statistic[numActiveSessions](title="number of active sessions"; source="sum(connect)"; record=max,timeavg,vector; interpolationmode=sample-hold);
        @statistic[numSessions](title="total number of sessions"; source="sum(connect+1)/2"; record=last);
    gates:
        input tcpIn @labels(TCPCommand/up);
        output tcpOut @labels(TCPCommand/down);
}
