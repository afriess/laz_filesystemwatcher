TSHChangeNotify traps certain events in the system and invokes a
event handler in your program when the corresponding event occurs,
passing information relating to the event. This makes it more
than SHChangeNotify, which only tells you an event has occurred
but not what it affected, but I figure the component's name is
already long enough.

Examples of events and what you receive are: CD inserted or removed
(the path of the CD drive); file renamed or moved (before and after
path and file names.

Install from source as usual for your version of Delphi.

You'll need the ShlObj unit, which is included for those who
don't have it. This copy includes the fixes from Brad Stowers'
Delphi Free Stuff page (www.delphifreestuff.com).

//*************************************************************
//*************************************************************
//* TSHChangeNotify component by Elliott Shevin  shevine@aol.com
//* vers. 3.0, May 2, 2000
//
//   Changes from version 1.0:
//       The Start and Stop methods, and the Options property,
//       have been eliminated. It's now only necessary to set
//       event handlers to designate which events you want to
//       intercept and start trapping them.
//
//   Changes from version 1.1:
//       The code in both the component and in the sample
//       program have been modified to work with both Delphi 2
//       and with later versions. In compiling the sample
//       program in Delphi 3 and later, you'll probably get
//       message boxes warning you about incompatibilities
//       in the parameter lists of the event handlers and
//       the corresponding declarations in the component;
//       just indicate the handler should be retained, and
//       it'll work fine. Of course, you won't have this
//       problem when you add the component to your own
//       projects.
//       The SHCNE_INTERRUPT event was eliminated because
//       of range problems in the component's "case" statement
//       (SHCNE_INTERRUPT is a negative integer). If that's
//       a problem, let me know.
//
//   Changes from version 1.2:
//       The SHCNE_INTERRUPT is now handled properly.
//
//   Changes from version 2.0:
//       The Execute and Stop methods are restored, in the interest
//       of efficiency.
//       In earlier versions, it was impossible to shut down the
//       system while monitoring was active; this has been corrected.
//       A notify event is available by which the component will
//       notify the caller that a shutdown has been requested;
//       the caller may halt the shutdown process if desired.
//       Monitoring may be limited to local hard drives if desired.
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
//*
//*  Methods:
//*     None.
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
//*   I'd be honored to hear what you think of this component.
//*   You can write me at shevine@aol.com.
//*************************************************************
//*************************************************************
