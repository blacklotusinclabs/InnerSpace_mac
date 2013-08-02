
#import <AppKit/NSView.h>

// based on xneko by Masayuki Koba

#define	BITMAP_WIDTH		32
#define	BITMAP_HEIGHT		32

#define	MAX_TICK		9999		/* Odd Only! */

#define	IDLE_SPACE		6

#define	STATE_STOP		0
#define	STATE_JARE		1
#define	STATE_KAKI		2
#define	STATE_AKUBI		3
#define	STATE_SLEEP		4
#define	STATE_AWAKE		5
#define	STATE_U_MOVE		6
#define	STATE_D_MOVE		7
#define	STATE_L_MOVE		8
#define	STATE_R_MOVE		9
#define	STATE_UL_MOVE		10
#define	STATE_UR_MOVE		11
#define	STATE_DL_MOVE		12
#define	STATE_DR_MOVE		13
#define	STATE_U_TOGI		14
#define	STATE_D_TOGI		15
#define	STATE_L_TOGI		16
#define	STATE_R_TOGI		17

#define	TIME_STOP		4
#define	TIME_JARE		10
#define	TIME_KAKI		4
#define	TIME_AKUBI		3
#define	TIME_AWAKE		3
#define	TIME_TOGI		10

#define Space (0.0*BITMAP_WIDTH)
#define Mati2 (1.0*BITMAP_WIDTH)
#define Jare2 (2.0*BITMAP_WIDTH)
#define Kaki1 (3.0*BITMAP_WIDTH)
#define Kaki2 (4.0*BITMAP_WIDTH)
#define Mati3 (5.0*BITMAP_WIDTH)
#define Sleep1 (6.0*BITMAP_WIDTH)
#define Sleep2 (7.0*BITMAP_WIDTH)
#define Awake (8.0*BITMAP_WIDTH)
#define Down1 (9.0*BITMAP_WIDTH)
#define Down2 (10.0*BITMAP_WIDTH)
#define Up1 (11.0*BITMAP_WIDTH)
#define Up2 (12.0*BITMAP_WIDTH)
#define Left1 (13.0*BITMAP_WIDTH)
#define Left2 (14.0*BITMAP_WIDTH)
#define Right1 (15.0*BITMAP_WIDTH)
#define Right2 (16.0*BITMAP_WIDTH)
#define DownLeft1 (17.0*BITMAP_WIDTH)
#define DownLeft2 (18.0*BITMAP_WIDTH)
#define DownRight1 (19.0*BITMAP_WIDTH)
#define DownRight2 (20.0*BITMAP_WIDTH)
#define UpLeft1 (21.0*BITMAP_WIDTH)
#define UpLeft2 (22.0*BITMAP_WIDTH)
#define UpRight1 (23.0*BITMAP_WIDTH)
#define UpRight2 (24.0*BITMAP_WIDTH)
#define DownTogi1 (25.0*BITMAP_WIDTH)
#define DownTogi2 (26.0*BITMAP_WIDTH)
#define UpTogi1 (27.0*BITMAP_WIDTH)
#define UpTogi2 (28.0*BITMAP_WIDTH)
#define LeftTogi1 (29.0*BITMAP_WIDTH)
#define LeftTogi2 (30.0*BITMAP_WIDTH)
#define RightTogi1 (31.0*BITMAP_WIDTH)
#define RightTogi2 (32.0*BITMAP_WIDTH)

@interface NekoView:NSView
{
    int	NekoTickCount;
    int	NekoStateCount;
    int	NekoState;
    int	MouseX;
    int	MouseY;
    int	PrevMouseX;
    int	PrevMouseY;
    NSRect	NekoPos;
    int	NekoMoveDx;
    int	NekoMoveDy;
    NSPoint	NekoLastXY;
    NSRect	NekoLastIcon;
    double	NekoSpeed;
    id	bitmaps;
	id	inspectorPanel;
	id	infoWindow;
	int randCount1;
}

- TickCount;
- SetNekoState: (int) SetValue;
- DrawNeko: (CGFloat) DrawIcon;
- NekoDirection;
- (BOOL) IsNekoDontMove;
- (BOOL) IsNekoMoveStart;
- CalcDxDy;
- oneStep;
- NekoAdjust;
- setBitmaps:anObject;
- bitmaps;
- (NSString *) windowTitle;
- (id)inspector:(id)sender;
- (BOOL) useBufferedWindow;
- (NSImage *)findImageNamed:(NSString *)name;

@end
