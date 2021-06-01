/*
 *  Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

import UIKit

@objc class ConferenceView: UIView {
    private struct Participant {
        let place: Int
        var view: ConferenceParticipantView
    }

    private struct PendingParticipant {
        var view: ConferenceParticipantView
        var renderer: ((_ view: UIView?) -> Void)? = nil
    }

    private var enlargedParticipantId: String?
    private var participants = [String: Participant]()
    private var pendingParticipants = [String: PendingParticipant]()
    private let maxNumberOfViews = 4
    private var defaultParticipantView: ConferenceParticipantView {
        let view = ConferenceParticipantView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleParticipant))
        view.addGestureRecognizer(tapGesture)
        view.frame = CGRect(x: self.bounds.width / 2, y: self.bounds.height / 2, width: 0, height: 0)
        return view
    }
    
    @objc var enlargeParticipantHandler: ((Bool) -> Void)?

    @objc func addParticipant(id: String, name: String? = nil) {
        guard participants[id] == nil, pendingParticipants[id] == nil else {
            print("addParticipant: unexpected branch")
            return
        }
        let participantView = defaultParticipantView
        participantView.name = name
        if participants.count < maxNumberOfViews {
            addSubview(participantView)
            let participant = Participant(place: participants.count, view: participantView)
            participants[id] = participant
        } else {
            let participant = PendingParticipant(view: participantView)
            pendingParticipants[id] = participant
        }
        rearrange()
    }

    @objc func removeParticipant(id: String) {
        if let participant = participants.removeValue(forKey: id) {
            participant.view.removeFromSuperview()
            if (id == enlargedParticipantId) {
                enlargedParticipantId = nil
            }
            if participants.count < maxNumberOfViews,
               let (participantId, pendingParticipant) = pendingParticipants.first {
                pendingParticipants[participantId] = nil
                participants[participantId] = Participant(
                    place: participants.count,
                    view: pendingParticipant.view
                )
                pendingParticipant.renderer?(pendingParticipant.view.streamView)
                addSubview(pendingParticipant.view)
            }
            rearrange()
        } else {
            pendingParticipants[id] = nil
        }
    }

    @objc func requestRendering(participantId id: String, render: @escaping (_ view: UIView?) -> Void) {
        if let participant = participants[id] {
            participant.view.isVideoEnabled = true
            render(participant.view.streamView)
        } else if pendingParticipants[id] != nil {
            pendingParticipants[id]?.renderer = render
        } else {
            print("requestRendering: unexpected branch")
        }
    }

    @objc func stopRendering(participantId id: String) {
        if let participant = participants[id] {
            participant.view.isVideoEnabled = false
        } else if let pendingParticipant = pendingParticipants[id] {
            pendingParticipant.view.isVideoEnabled = false
            pendingParticipants[id]?.renderer = nil
        }
    }

    @objc func updateParticipantName(id: String, name: String) {
        if let participantView = participants[id]?.view {
            participantView.name = name
        } else if let pendingParticipantView = pendingParticipants[id]?.view {
            pendingParticipantView.name = name
        }
    }

    @objc private func toggleParticipant(_ sender: UIGestureRecognizer!) {
        if let participantView = sender.view as? ConferenceParticipantView,
           let id = participants.first(where: { _, value in value.view == participantView })?.key {
            if id == enlargedParticipantId {
                enlargedParticipantId = nil
            } else {
                enlargedParticipantId = id
            }
        }
        rearrange()
    }

    override func layoutSubviews() {
        rearrange()
        super.layoutSubviews()
    }

    private func rearrange() {
        DispatchQueue.main.async { () -> Void in
            self.enlargeParticipantHandler?(self.enlargedParticipantId != nil)
            
            let surface = self.bounds.size

            if let rootParticipant = self.enlargedParticipantId {
                guard let rootParticipantView = self.participants[rootParticipant]?.view
                    else { return }
                self.participants.values.forEach { $0.view.alpha = 0 }
                rootParticipantView.isNameEnabled = true
                rootParticipantView.frame = CGRect(x: 0, y: 0, width: surface.width, height: surface.height)
                rootParticipantView.alpha = 1

            } else {
                var w, h: CGFloat

                switch self.participants.count {
                case 0..<2:
                    w = 1; h = 1
                case 2:
                    w = 2; h = 1
                case 3..<5:
                    w = 2; h = 2
                default:
                    return
                }

                let size = CGSize(width: surface.width / w, height: surface.height / h)
                self.participants.values.forEach { participant in
                    let view = participant.view
                    view.alpha = 1
                    view.isNameEnabled = false
                    let x = participant.place % Int(w)
                    let y = participant.place / Int(w)
                    view.frame = CGRect(
                        origin: CGPoint(x: CGFloat(x) * size.width, y: CGFloat(y) * size.height),
                        size: size
                    )
                    view.layoutSubviews()
                }
            }
        }
    }
}
