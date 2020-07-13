//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Cluster Membership open source project
//
// Copyright (c) 2018-2020 Apple Inc. and the Swift Cluster Membership project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Cluster Membership project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import ClusterMembership

extension SWIM {
    public typealias Peer = SWIMPeerProtocol
    public typealias AnyPeer = AnySWIMPeer
}

public protocol SWIMPeerProtocol {
    /// Node that this peer is representing.
    var node: ClusterMembership.Node { get }

    /// "Ping" another SWIM peer.
    func ping(
        payload: SWIM.GossipPayload,
        from origin: SWIMPeerProtocol,
        timeout: TimeAmount,
        onComplete: @escaping (Result<SWIM.PingResponse, Error>) -> Void
    )

    /// "Ping Request" a SWIM peer.
    func pingReq(
        target: SWIMPeerProtocol,
        payload: SWIM.GossipPayload,
        from origin: SWIMPeerProtocol,
        timeout: TimeAmount,
        onComplete: @escaping (Result<SWIM.PingResponse, Error>) -> Void
    )

    /// "Ack"-nowledge a ping.
    func ack(target: SWIMPeerProtocol, incarnation: SWIM.Incarnation, payload: SWIM.GossipPayload)

    /// "NegativeAcknowledge" a ping.
    func nack(target: SWIMPeerProtocol)

    /// Type erase this member into an `AnySWIMMember`
    var asAnyMember: AnySWIMPeer { get }
}

extension SWIM.Peer {
    public var asAnyMember: AnySWIMPeer {
        .init(peer: self)
    }
}

public struct AnySWIMPeer: Hashable, SWIMPeerProtocol {
    let peer: SWIMPeerProtocol

    public init(peer: SWIMPeerProtocol) {
        self.peer = peer
    }

    public var node: ClusterMembership.Node {
        self.peer.node
    }

    public func ping(
        payload: SWIM.GossipPayload,
        from origin: SWIMPeerProtocol,
        timeout: TimeAmount,
        onComplete: @escaping (Result<SWIM.PingResponse, Error>) -> Void
    ) {
        self.peer.ping(payload: payload, from: origin, timeout: timeout, onComplete: onComplete)
    }

    public func pingReq(
        target: SWIMPeerProtocol,
        payload: SWIM.GossipPayload,
        from origin: SWIMPeerProtocol,
        timeout: TimeAmount,
        onComplete: @escaping (Result<SWIM.PingResponse, Error>) -> Void
    ) {
        self.peer.pingReq(target: target, payload: payload, from: origin, timeout: timeout, onComplete: onComplete)
    }

    public func ack(target: SWIMPeerProtocol, incarnation: SWIM.Incarnation, payload: SWIM.GossipPayload) {
        self.peer.ack(target: target, incarnation: incarnation, payload: payload)
    }

    public func nack(target: SWIMPeerProtocol) {
        self.peer.nack(target: target)
    }

    public func hash(into hasher: inout Hasher) {
        self.peer.node.hash(into: &hasher)
    }

    public static func == (lhs: AnySWIMPeer, rhs: AnySWIMPeer) -> Bool {
        lhs.peer.node == rhs.peer.node
    }
}
