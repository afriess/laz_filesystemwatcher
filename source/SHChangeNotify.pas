unit SHChangeNotify ;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$IFNDEF VER80} {$IFNDEF VER90} {$IFNDEF VER93}
{$DEFINE Delphi3orHigher}
{$ENDIF} {$ENDIF} {$ENDIF}
//*************************************************************
//*************************************************************
// TSHChangeNotify component by Elliott Shevin  shevine@aol.com
// vers. 3.0, October 2000
//
//   See the README.TXT file for revision history.
//
//*
//*  I owe this component to James Holderness, who described the
//*  use of the undocumented Windows API calls it depends upon,
//*  and Brad Martinez, who coded a similar function in Visual
//*  Basic. I quote here from Brad's expression of gratitude to
//*  James:
//*     Interpretation of the shell's undocumented functions
//*     SHChangeNotifyRegister (ordinal 2) and SHChangeNotifyDeregister
//*     (ordinal 4) would not have been possible without the
//*     assistance of James Holderness. For a complete (and probably
//*     more accurate) overview of shell change notifcations,
//*     please refer to James'  "Shell Notifications" page at
//*     http://www.geocities.com/SiliconValley/4942/
//*
//*  This component will let you know when selected events
//*  occur in the Windows shell, such as files and folders
//*  being renamed, added, or deleted. (Moving an item yields
//*  the same results as renaming it.) For the complete list
//*  of events the component can trap, see Win32 Programmer's
//*  reference description of the SHChangeNotify API call.
//*
//*  Properties:
//*     MessageNo: the Windows message number which will be used to signal
//*                a trapped event. The default is WM_USER (1024); you may
//*                set it to some other value if you're using WM_USER for
//*                any other purpose.
//*     TextCase:  tcAsIs (default), tcLowercase, or tcUppercase, determines
//*                whether and how the Path parameters passed to your event
//*                handlers are case-converted.
//*     HardDriveOnly: when set to True, the component monitors only local
//*                hard drive partitions; when set to False, monitors the
//*                entire file system.
//*
//*  Methods:
//*     Execute:   Begin monitoring the selected shell events.
//*     Stop:      Stop monitoring.
//*
//*  Events:
//*     The component has an event corresponding to each event it can
//*     trap, e.g. OnCreate, OnMediaInsert, etc.
//*     Each event handler is passed either three or four parameters--
//*          Sender=this component.
//*          Flags=the value indentifying the event that triggered the handler,
//*             from the constants in the SHChangeNotify help. This parameter
//*             allows multiple events to share handlers and still distinguish
//*             the reason the handler was triggered.
//*          Path1, Path2: strings which are the paths affected by the shell
//*             event. Whether both are passed depends on whether the second
//*             is needed to describe the event. For example, OnDelete gives
//*             only the name of the file (including path) that was deleted;
//*             but OnRenameFolder gives the original folder name in Path1
//*             and the new name in Path2.
//*             In some cases, such as OnAssocChanged, neither Path parameter
//*             means anything, and in other cases, I guessed, but we always
//*             pass at least one.
//*     Each time an event property is changed, the component is reset to
//*     trap only those events for which handlers are assigned. So assigning
//*     an event handler suffices to indicate your intention to trap the
//*     corresponding shell event.
//*
//*     There is one more event: OnEndSessionQuery, which has the same
//*     parameters as the standard Delphi OnCloseQuery (and can in fact
//*     be your OnCloseQuery handler). This component must shut down its
//*     interception of shell events when system shutdown is begun, lest
//*     the system fail to shut down at the user's request.
//*
//*     Setting CanEndSession (same as CanClose) to FALSE in an
//*     OnEndSessionQuery will stop the process of shutting down
//*     Windows. You would only need this if you need to keep the user
//*     from ending his Windows session while your program is running.
//*
//*   I'd be honored to hear what you think of this component.
//*   You can write me at shevine@aol.com.
//*************************************************************
//*************************************************************

interface

uses

  Windows,

//  LCLIntf, LCLType, LMessages,

  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
{$IFNDEF Delphi3orHigher}
  OLE2,
{$ELSE}
  ActiveX,
  ComObj,
{$ENDIF}
  ShlObj ;

const
  SHCNF_ACCEPT_INTERRUPTS = $0001 ;
  SHCNF_ACCEPT_NON_INTERRUPTS = $0002 ;
  SHCNF_NO_PROXY = $8000 ;

type
  NOTIFYREGISTER = record
    pidlPath : PItemIDList ;
    bWatchSubtree : boolean ;
  end ;

type
  PNOTIFYREGISTER = ^NOTIFYREGISTER ;

type
  TTextCase = ( tcAsIs, tcUppercase, tcLowercase ) ;

type
  TOneParmEvent = procedure( Sender : TObject ; Flags : cardinal ; Path1 : string ) of object ;
  TTwoParmEvent = procedure( Sender : TObject ; Flags : cardinal ; Path1, Path2 : string ) of object ;
  TEndSessionQueryEvent = procedure( Sender : TObject ; var CanEndSession : boolean ) of object ;

function SHChangeNotifyRegister( hWnd : hWnd ; dwFlags : integer ; wEventMask : cardinal ; uMsg : UINT ;
  cItems : integer ; lpItems : PNOTIFYREGISTER ) : hWnd ; stdcall ;
function SHChangeNotifyDeregister( hWnd : hWnd ) : boolean ; stdcall ;
function SHILCreateFromPath( Path : Pointer ; PIDL : PItemIDList ; var Attributes : ULONG ) : HResult ; stdcall ;

type
  TSHChangeNotify = class( TComponent )
  private
    fTextCase : TTextCase ;
    fHardDriveOnly : boolean ;
    NotifyCount : integer ;
    NotifyHandle : hWnd ;
    NotifyArray : array [ 1 .. 26 ] of NOTIFYREGISTER ;
    AllocInterface : IMalloc ;
    PrevMsg : integer ;
    prevpath1 : string ;
    prevpath2 : string ;
    fMessageNo : integer ;
    fAssocChanged : TTwoParmEvent ;
    fAttributes : TOneParmEvent ;
    fCreate : TOneParmEvent ;
    fDelete : TOneParmEvent ;
    fDriveAdd : TOneParmEvent ;
    fDriveAddGUI : TOneParmEvent ;
    fDriveRemoved : TOneParmEvent ;
    fMediaInserted : TOneParmEvent ;
    fMediaRemoved : TOneParmEvent ;
    fMkDir : TOneParmEvent ;
    fNetShare : TOneParmEvent ;
    fNetUnshare : TOneParmEvent ;
    fRenameFolder : TTwoParmEvent ;
    fRenameItem : TTwoParmEvent ;
    fRmDir : TOneParmEvent ;
    fServerDisconnect : TOneParmEvent ;
    fUpdateDir : TOneParmEvent ;
    fUpdateImage : TOneParmEvent ;
    fUpdateItem : TOneParmEvent ;
    fEndSessionQuery : TEndSessionQueryEvent ;

    OwnerWindowProc : TWndMethod ;

    procedure SetMessageNo( value : integer ) ;
    procedure WndProc( var msg : TMessage ) ;

  protected
    procedure QueryEndSession( var msg : TMessage ) ;

  public
    constructor Create( AOwner : TComponent ) ; override ;
    destructor Destroy ; override ;
    procedure Execute ;
    procedure Stop ;

  published
    property MessageNo : integer read fMessageNo write SetMessageNo default WM_USER ;
    property TextCase : TTextCase read fTextCase write fTextCase default tcAsIs ;
    property HardDriveOnly : boolean read fHardDriveOnly write fHardDriveOnly default True ;

    property OnAssocChanged : TTwoParmEvent read fAssocChanged write fAssocChanged ;
    property OnAttributes : TOneParmEvent read fAttributes write fAttributes ;
    property OnCreate : TOneParmEvent read fCreate write fCreate ;
    property OnDelete : TOneParmEvent read fDelete write fDelete ;
    property OnDriveAdd : TOneParmEvent read fDriveAdd write fDriveAdd ;
    property OnDriveAddGUI : TOneParmEvent read fDriveAddGUI write fDriveAddGUI ;
    property OnDriveRemoved : TOneParmEvent read fDriveRemoved write fDriveRemoved ;
    property OnMediaInserted : TOneParmEvent read fMediaInserted write fMediaInserted ;
    property OnMediaRemoved : TOneParmEvent read fMediaRemoved write fMediaRemoved ;
    property OnMkDir : TOneParmEvent read fMkDir write fMkDir ;
    property OnNetShare : TOneParmEvent read fNetShare write fNetShare ;
    property OnNetUnshare : TOneParmEvent read fNetUnshare write fNetUnshare ;
    property OnRenameFolder : TTwoParmEvent read fRenameFolder write fRenameFolder ;
    property OnRenameItem : TTwoParmEvent read fRenameItem write fRenameItem ;
    property OnRmDir : TOneParmEvent read fRmDir write fRmDir ;
    property OnServerDisconnect : TOneParmEvent read fServerDisconnect write fServerDisconnect ;
    property OnUpdateDir : TOneParmEvent read fUpdateDir write fUpdateDir ;
    property OnUpdateImage : TOneParmEvent read fUpdateImage write fUpdateImage ;
    property OnUpdateItem : TOneParmEvent read fUpdateItem write fUpdateItem ;
    property OnEndSessionQuery : TEndSessionQueryEvent read fEndSessionQuery write fEndSessionQuery ;
    { Published declarations }
  end ;

procedure register ;

implementation

const
  Shell32DLL = 'shell32.dll' ;

function SHChangeNotifyRegister ; external Shell32DLL index 2 ;
function SHChangeNotifyDeregister ; external Shell32DLL index 4 ;
function SHILCreateFromPath ; external Shell32DLL index 28 ;

procedure register ;
begin
  RegisterComponents( 'Custom', [ TSHChangeNotify ] ) ;
end ;

// Set defaults, and ensure NotifyHandle is zero.
constructor TSHChangeNotify.Create( AOwner : TComponent ) ;
begin
  inherited Create( AOwner ) ;
  fTextCase := tcAsIs ;
  fHardDriveOnly := True ;

  fAssocChanged := nil ;
  fAttributes := nil ;
  fCreate := nil ;
  fDelete := nil ;
  fDriveAdd := nil ;
  fDriveAddGUI := nil ;
  fDriveRemoved := nil ;
  fMediaInserted := nil ;
  fMediaRemoved := nil ;
  fMkDir := nil ;
  fNetShare := nil ;
  fNetUnshare := nil ;
  fRenameFolder := nil ;
  fRenameItem := nil ;
  fRmDir := nil ;
  fServerDisconnect := nil ;
  fUpdateDir := nil ;
  fUpdateImage := nil ;
  fUpdateItem := nil ;
  fEndSessionQuery := nil ;

  MessageNo := WM_USER ;

  // If designing, dodge the code that implements messag interception.
  if csDesigning in ComponentState then
    exit ;

  // Substitute our window proc for our owner's window proc.
  if (Owner is TWinControl) then begin
    OwnerWindowProc := ( Owner as TWinControl ).WindowProc ;
    (Owner as TWinControl ).WindowProc := WndProc;
  end
  else begin
     OwnerWindowProc := ( Application.MainForm as TWinControl ).WindowProc ;
     ( Application.MainForm as TWinControl ).WindowProc := WndProc
  end;

  // Get the IMAlloc interface so we can free PIDLs.
  SHGetMalloc( AllocInterface ) ;

end ;

procedure TSHChangeNotify.SetMessageNo( value : integer ) ;
begin
  if ( value >= WM_USER ) then
    fMessageNo := value
  else
    raise Exception.Create( 'MessageNo must be greater than or equal to ' + inttostr( WM_USER ) ) ;
end ;

// Execute unregisters any current notification and registers a new one.
procedure TSHChangeNotify.Execute ;
var
  EventMask : integer ;
  driveletter : string ;
  i : integer ;
  PIDL : PItemIDList ;
  Attributes : ULONG ;
  NotifyPtr : PNOTIFYREGISTER ;
begin
  NotifyCount := 0 ;

  if csDesigning in ComponentState then
    exit ;

  Stop ; // Unregister the current notification, if any.

  EventMask := 0 ;
  if assigned( fAssocChanged ) then
    EventMask := ( EventMask or SHCNE_ASSOCCHANGED ) ;
  if assigned( fAttributes ) then
    EventMask := ( EventMask or SHCNE_ATTRIBUTES ) ;
  if assigned( fCreate ) then
    EventMask := ( EventMask or SHCNE_CREATE ) ;
  if assigned( fDelete ) then
    EventMask := ( EventMask or SHCNE_DELETE ) ;
  if assigned( fDriveAdd ) then
    EventMask := ( EventMask or SHCNE_DRIVEADD ) ;
  if assigned( fDriveAddGUI ) then
    EventMask := ( EventMask or SHCNE_DRIVEADDGUI ) ;
  if assigned( fDriveRemoved ) then
    EventMask := ( EventMask or SHCNE_DRIVEREMOVED ) ;
  if assigned( fMediaInserted ) then
    EventMask := ( EventMask or SHCNE_MEDIAINSERTED ) ;
  if assigned( fMediaRemoved ) then
    EventMask := ( EventMask or SHCNE_MEDIAREMOVED ) ;
  if assigned( fMkDir ) then
    EventMask := ( EventMask or SHCNE_MKDIR ) ;
  if assigned( fNetShare ) then
    EventMask := ( EventMask or SHCNE_NETSHARE ) ;
  if assigned( fNetUnshare ) then
    EventMask := ( EventMask or SHCNE_NETUNSHARE ) ;
  if assigned( fRenameFolder ) then
    EventMask := ( EventMask or SHCNE_RENAMEFOLDER ) ;
  if assigned( fRenameItem ) then
    EventMask := ( EventMask or SHCNE_RENAMEITEM ) ;
  if assigned( fRmDir ) then
    EventMask := ( EventMask or SHCNE_RMDIR ) ;
  if assigned( fServerDisconnect ) then
    EventMask := ( EventMask or SHCNE_SERVERDISCONNECT ) ;
  if assigned( fUpdateDir ) then
    EventMask := ( EventMask or SHCNE_UPDATEDIR ) ;
  if assigned( fUpdateImage ) then
    EventMask := ( EventMask or SHCNE_UPDATEIMAGE ) ;
  if assigned( fUpdateItem ) then
    EventMask := ( EventMask or SHCNE_UPDATEITEM ) ;

  if EventMask = 0 // If there's no event mask
    then
    exit ; // then there's no need to set an event.

  // If the user requests watches on hard drives only, cycle through
  // the list of drive letters and add a NotifyList element for each.
  // Otherwise, just set the first element to watch the entire file
  // system.
  if fHardDriveOnly then
    for i := ord( 'A' ) to ord( 'Z' ) do begin
      driveletter := char( i ) + ':\' ;
      if GetDriveType( pchar( driveletter ) ) = DRIVE_FIXED then begin
        inc( NotifyCount ) ;
        with NotifyArray[ NotifyCount ] do begin
          SHILCreateFromPath( pchar( driveletter ), addr( PIDL ), Attributes ) ;
          pidlPath := PIDL ;
          bWatchSubtree := True ;
        end ;
      end ;
    end

    // If the caller requests the entire file system be watched,
    // prepare the first NotifyElement accordingly.
    else begin
      NotifyCount := 1 ;
      with NotifyArray[ 1 ] do begin
        pidlPath := nil ;
        bWatchSubtree := True ;
      end ;
    end ;

  NotifyPtr := addr( NotifyArray ) ;

  NotifyHandle := SHChangeNotifyRegister( ( Owner as TWinControl ).Handle,
    SHCNF_ACCEPT_INTERRUPTS + SHCNF_ACCEPT_NON_INTERRUPTS, EventMask, fMessageNo, NotifyCount, NotifyPtr ) ;

  if NotifyHandle = 0 then begin
    Stop ;
    raise Exception.Create( 'Could not register SHChangeNotify' ) ;
  end ;
end ;

// This procedure unregisters the Change Notification
procedure TSHChangeNotify.Stop ;
var
//  NotifyHandle : hWnd ;
  i : integer ;
  PIDL : PItemIDList ;
begin
  if csDesigning in ComponentState then
    exit ;

  // Deregister the shell notification.
  if NotifyCount > 0 then
    SHChangeNotifyDeregister( NotifyHandle ) ;

  // Free the PIDLs in NotifyArray.
  for i := 1 to NotifyCount do begin
    PIDL := NotifyArray[ i ].pidlPath ;
    if AllocInterface.DidAlloc( PIDL ) = 1 then
      AllocInterface.Free( PIDL ) ;
  end ;

  NotifyCount := 0 ;
end ;

// This is the procedure that is called when a change notification occurs.
// It interprets the two PIDLs passed to it, and calls the appropriate
// event handler, according to what kind of event occurred.
procedure TSHChangeNotify.WndProc( var msg : TMessage ) ;
type
  TPIDLLIST = record
    pidlist : array [ 1 .. 2 ] of PItemIDList ;
  end ;

  PIDARRAY = ^TPIDLLIST ;
var
  Path1 : string ;
  Path2 : string ;
  ptr : PIDARRAY ;
  p1, p2 : PItemIDList ;
  repeated : boolean ;
  p : integer ;
  event : longint ;
  parmcount : byte ;
  OneParmEvent : TOneParmEvent ;
  TwoParmEvent : TTwoParmEvent ;

  // The internal function ParsePidl returns the string corresponding
  // to a PIDL.
  function ParsePidl( PIDL : PItemIDList ) : string ;
  begin
    SetLength( result, MAX_PATH ) ;
    if not SHGetPathFromIDList( PIDL, pchar( result ) ) then
      result := '' ;
  end ;

// The actual message handler starts here.
begin
  if msg.msg = WM_QUERYENDSESSION then
    QueryEndSession( msg ) ;

  if msg.msg = fMessageNo then begin
    OneParmEvent := nil ;
    TwoParmEvent := nil ;

    event := msg.LParam and ( $7FFFFFFF ) ;

    case event of
    SHCNE_ASSOCCHANGED :
      TwoParmEvent := fAssocChanged ;
    SHCNE_ATTRIBUTES :
      OneParmEvent := fAttributes ;
    SHCNE_CREATE :
      OneParmEvent := fCreate ;
    SHCNE_DELETE :
      OneParmEvent := fDelete ;
    SHCNE_DRIVEADD :
      OneParmEvent := fDriveAdd ;
    SHCNE_DRIVEADDGUI :
      OneParmEvent := fDriveAddGUI ;
    SHCNE_DRIVEREMOVED :
      OneParmEvent := fDriveRemoved ;
    SHCNE_MEDIAINSERTED :
      OneParmEvent := fMediaInserted ;
    SHCNE_MEDIAREMOVED :
      OneParmEvent := fMediaRemoved ;
    SHCNE_MKDIR :
      OneParmEvent := fMkDir ;
    SHCNE_NETSHARE :
      OneParmEvent := fNetShare ;
    SHCNE_NETUNSHARE :
      OneParmEvent := fNetUnshare ;
    SHCNE_RENAMEFOLDER :
      TwoParmEvent := fRenameFolder ;
    SHCNE_RENAMEITEM :
      TwoParmEvent := fRenameItem ;
    SHCNE_RMDIR :
      OneParmEvent := fRmDir ;
    SHCNE_SERVERDISCONNECT :
      OneParmEvent := fServerDisconnect ;
    SHCNE_UPDATEDIR :
      OneParmEvent := fUpdateDir ;
    SHCNE_UPDATEIMAGE :
      OneParmEvent := fUpdateImage ;
    SHCNE_UPDATEITEM :
      OneParmEvent := fUpdateItem ;
    else
      begin
        OneParmEvent := nil ; // Unknown event;
        TwoParmEvent := nil ;
      end ;
    end ;
    if ( assigned( OneParmEvent ) ) or ( assigned( TwoParmEvent ) ) then begin

      // Assign a pointer to the array of PIDLs sent
      // with the message.
      ptr := PIDARRAY( msg.wParam ) ;

      // Parse the two PIDLs.
      p1 := ptr^.pidlist[ 1 ] ;
      try
        SetLength( Path1, MAX_PATH ) ;
        Path1 := ParsePidl( p1 ) ;
        p := pos( #00, Path1 ) ;
        if p > 0 then
          SetLength( Path1, p - 1 ) ;
      except
        Path1 := '' ;
      end ;

      p2 := ptr^.pidlist[ 2 ] ;
      try
        SetLength( Path2, MAX_PATH ) ;
        Path2 := ParsePidl( p2 ) ;
        p := pos( #00, Path2 ) ;
        if p > 0 then
          SetLength( Path2, p - 1 ) ;
      except
        Path2 := '' ;
      end ;

      // If this message is the same as the last one (which happens
      // a lot), bail out.
      try
        repeated := ( PrevMsg = event ) and ( uppercase( prevpath1 ) = uppercase( Path1 ) ) and
          ( uppercase( prevpath2 ) = uppercase( Path2 ) ) except repeated := false ;
      end ;

      // Save the elements of this message for comparison next time.
      PrevMsg := event ;
      prevpath1 := Path1 ;
      prevpath2 := Path2 ;

      // Convert the case of Path1 and Path2 if desired.
      case fTextCase of
      tcUppercase : begin
          Path1 := uppercase( Path1 ) ;
          Path2 := uppercase( Path2 ) ;
        end ;
      tcLowercase : begin
          Path1 := lowercase( Path1 ) ;
          Path2 := lowercase( Path2 ) ;
        end ;
      end ;

      // Call the event handler according to the number
      // of paths we will pass to it.
      if not repeated then begin
        case event of
        SHCNE_ASSOCCHANGED, SHCNE_RENAMEFOLDER, SHCNE_RENAMEITEM :
          parmcount := 2 ;
        else
          parmcount := 1 ;
        end ;

        if parmcount = 1 then
          OneParmEvent( self, event, Path1 )
        else
          TwoParmEvent( self, event, Path1, Path2 ) ;
      end ;

    end ; // if assigned(OneParmEvent)...

  end ; // if Msg.Msg = fMessageNo...

  // Call the original message handler.
  OwnerWindowProc( msg ) ;
end ;

procedure TSHChangeNotify.QueryEndSession( var msg : TMessage ) ;
var
  CanEndSession : boolean ;
begin
  CanEndSession := True ;
  if assigned( fEndSessionQuery ) then
    fEndSessionQuery( self, CanEndSession ) ;
  if CanEndSession then begin
    Stop ;
    msg.result := 1 ;
  end
  else
    msg.result := 0 ;
end ;

destructor TSHChangeNotify.Destroy ;
begin
  if not( csDesigning in ComponentState ) then begin
    if (Owner is TWinControl) then begin
     if assigned( Owner ) then ( Owner as TWinControl ).WindowProc := OwnerWindowProc ;
    end
    else begin
      if assigned( Application.MainForm ) then ( Application.MainForm as TWinControl ).WindowProc := OwnerWindowProc ;
    end;
    Stop ;
  end ;

  inherited ;
end ;

end.
