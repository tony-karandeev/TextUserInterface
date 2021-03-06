//
// CreateAccountContext.swift
//
// This source file is part of the SMUD open source project
//
// Copyright (c) 2016 SMUD project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SMUD project authors
//

import Foundation
import Smud

public final class ChooseAccountContext: SessionContext {
    let smud: Smud
    
    public init(smud: Smud) {
        self.smud = smud
    }
    
    public static var name = "chooseAccount"
    
    public func greet(session: Session) {
        session.sendPrompt("Please enter your email address: ")
    }
    
    public func processResponse(args: Scanner, session: Session) throws -> ContextAction {
        guard let email = args.scanWord(),
            Email.isValidEmail(email) else { return .retry(reason: "Invalid email address.") }
        
        if let account = smud.db.account(email: email) {
            session.account = account
            return .next(context: PlayerNameContext(smud: smud))
        }
        
        let account = Account(smud: smud)
        account.email = email
        account.scheduleForSaving()
        smud.db.addToIndexes(account: account)
        
        session.account = account
        
        session.send("Confirmation email has been sent to your email address.")
        return .next(context: ConfirmationCodeContext(smud: smud))
    }
}
