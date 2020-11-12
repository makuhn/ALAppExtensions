// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays an account that was registered via the SMTP connector.
/// </summary>
page 4512 "SMTP Account"
{
    SourceTable = "SMTP Account";
    Caption = 'SMTP Account';
    Permissions = tabledata "SMTP Account" = rimd;
    PageType = Card;
    Extensible = false;
    InsertAllowed = false;
    DataCaptionExpression = Rec.Name;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'Specifies the name of the SMTP account';
                ShowMandatory = true;
                NotBlank = true;
            }

            field(SenderNameField; Rec."Sender Name")
            {
                ApplicationArea = All;
                Caption = 'Sender Name';
                ToolTip = 'Specifies a name to add in front of the sender email address. For example, if you enter Stan in this field, and the email address is stan@cronus.com, the recipient will see the sender as Stan stan@cronus.com.';
            }

            field(EmailAddress; Rec."Email Address")
            {
                ApplicationArea = All;
                Caption = 'Email Address';
                ToolTip = 'Specifies the Email Address specified as the from email address.';
                ShowMandatory = true;
                NotBlank = true;

                trigger OnValidate()
                begin
                    if Rec."User Name" = '' then
                        Rec."User Name" := Rec."Email Address";
                end;
            }

            field(ServerUrl; Rec.Server)
            {
                ApplicationArea = All;
                Caption = 'Server Url';
                ToolTip = 'Specifies the name of the SMTP server.';
                ShowMandatory = true;
                NotBlank = true;
            }

            field(ServerPort; Rec."Server Port")
            {
                ApplicationArea = All;
                MinValue = 1;
                NotBlank = true;
                Caption = 'Server Port';
                ToolTip = 'Specifies the port of the SMTP server. The default setting is 25.';
            }

            field(Authentication; Rec.Authentication)
            {
                ApplicationArea = All;
                Caption = 'Authentication';
                ToolTip = 'Specifies the type of authentication that the SMTP mail server uses.';

                trigger OnValidate()
                begin
                    AuthenticationOnAfterValidate();
                end;
            }

            field(UserName; Rec."User Name")
            {
                ApplicationArea = All;
                Visible = UserIDEditable;
                Caption = 'User Name';
                ToolTip = 'Specifies the username to use when authenticating with the SMTP server.';
            }

            field(Password; Password)
            {
                ApplicationArea = All;
                Caption = 'Password';
                Visible = PasswordEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password of the SMTP server.';

                trigger OnValidate()
                begin
                    Rec.SetPassword(Password);
                end;
            }

            field(SecureConnection; Rec."Secure Connection")
            {
                ApplicationArea = All;
                Caption = 'Secure Connection';
                ToolTip = 'Specifies if your SMTP mail server setup requires a secure connection that uses a cryptography or security protocol, such as secure socket layers (SSL). Clear the check box if you do not want to enable this security setting.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ApplyOffice365)
            {
                ApplicationArea = All;
                Caption = 'Apply Office 365 Server Settings';
                ToolTip = 'Apply the Office 365 server settings to this record.';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if CurrPage.Editable() then begin
                        if not (Rec.Server = '') then
                            if not ConfirmManagement.GetResponseOrDefault(ConfirmApplyO365Qst, true) then
                                exit;

                        SMTPConnectorImpl.ApplyOffice365Smtp(Rec);

                        AuthenticationOnAfterValidate();
                        CurrPage.Update();
                    end
                end;
            }
        }
    }

    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        [InDataSet]
        UserIDEditable: Boolean;
        [InDataSet]
        PasswordEditable: Boolean;
        [InDataSet]
        Password: Text;
        ConfirmApplyO365Qst: Label 'Do you want to override the current data?';

    trigger OnInit()
    begin
        UserIDEditable := true;
        PasswordEditable := true;
    end;

    trigger OnOpenPage()
    var
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."Password Key") then
            Password := '***';

        AuthenticationOnAfterValidate();
    end;

    local procedure AuthenticationOnAfterValidate()
    begin
        UserIDEditable := Rec.Authentication = Rec.Authentication::Basic;
        PasswordEditable := Rec.Authentication = Rec.Authentication::Basic;
    end;
}