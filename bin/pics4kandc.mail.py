#!/usr/bin/env python3
#get_images_from_emails.py
# read emails and detach attachment in emails directory
 
import email
import getpass, imaplib
import os
import sys
import time
 
detach_dir = '.'
if 'emails' not in os.listdir(detach_dir):
    os.mkdir('emails')
 
userName = 'pics4keithandchanning'
passwd = 'Qwerty123!'
 
try:
    imapSession = imaplib.IMAP4_SSL('imap.gmail.com',993)
    typ, accountDetails = imapSession.login(userName, passwd)
    if typ != 'OK':
        print ('Not able to sign in!')
        raise Exception
 
    imapSession.select('Inbox')
    typ, data = imapSession.search(None, 'SUBJECT', '"#pictures"')
    if typ != 'OK':
        print ('Error searching Inbox.')
        raise Exception
 
    # Iterating over all emails
    for msgId in data[0].split():
        typ, messageParts = imapSession.fetch(msgId, '(RFC822)')
 
        if typ != 'OK':
            print ('Error fetching mail.')
            raise Exception
 
        emailBody = messageParts[0][1] 
        mail = email.message_from_bytes(emailBody) 
 
        for part in mail.walk():
 
            if part.get_content_maintype() == 'multipart':
 
                continue
            if part.get('Content-Disposition') is None:
 
                continue
 
            fileName = part.get_filename()
 
            if bool(fileName): 
                filePath = os.path.join(detach_dir, 'emails', fileName)
                if not os.path.isfile(filePath) : 
                    print (fileName)
                    print (filePath)
                    fp = open(filePath, 'wb')
                    fp.write(part.get_payload(decode=True))
                    fp.close()
 
    #MOVING EMAILS TO PROCESSED PART BEGINS HERE
    imapSession.select(mailbox='inbox', readonly=False)
    resp, items = imapSession.search(None, 'All')
    email_ids = items[0].split()
    for email in email_ids:
        latest_email_id = email
 
        #move to processed
        result = imapSession.store(latest_email_id, '+X-GM-LABELS', 'Processed')
 
        if result[0] == 'OK':
            #delete from inbox
            imapSession.store(latest_email_id, '+FLAGS', '\\Deleted')
 
    #END OF MOVING EMAILS TO PROCESSED
 
    imapSession.close()
    imapSession.logout()
 
except :
    print ('No attachments were downloaded')

