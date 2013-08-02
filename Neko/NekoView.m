
#import "NekoView.h"
#import "PSOperators.h"
// #import "Thinker.h"

// based on xneko by Masayuki Koba
// hacked into NeXTstep by Eric P. Scott
// severely munged into BackSpace by sam streeper
// go back to the X sources if you port this to other platforms...

#import <libc.h>
#import <math.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSImage.h>
// #import <dpsclient/wraps.h>

const CGFloat Even[]={
	Mati2,	// STATE_STOP
	Jare2,	// STATE_JARE
	Kaki1,	// STATE_KAKI
	Mati3,	// STATE_AKUBI
	Sleep1,	// STATE_SLEEP
	Awake,	// STATE_AWAKE
	Up1,	// STATE_U_MOVE
	Down1,	// STATE_D_MOVE
	Left1,	// STATE_L_MOVE
	Right1,	// STATE_R_MOVE
	UpLeft1,	// STATE_UL_MOVE
	UpRight1,	// STATE_UR_MOVE
	DownLeft1,	// STATE_DL_MOVE
	DownRight1,	// STATE_DR_MOVE
	UpTogi1,	// STATE_U_TOGI
	DownTogi1,	// STATE_D_TOGI
	LeftTogi1,	// STATE_L_TOGI
	RightTogi1	// STATE_R_TOGI
};

const CGFloat Odd[]={
	Mati2,	// STATE_STOP
	Mati2,	// STATE_JARE
	Kaki2,	// STATE_KAKI
	Mati3,	// STATE_AKUBI
	Sleep2,	// STATE_SLEEP
	Awake,	// STATE_AWAKE
	Up2,	// STATE_U_MOVE
	Down2,	// STATE_D_MOVE
	Left2,	// STATE_L_MOVE
	Right2,	// STATE_R_MOVE
	UpLeft2,	// STATE_UL_MOVE
	UpRight2,	// STATE_UR_MOVE
	DownLeft2,	// STATE_DL_MOVE
	DownRight2,	// STATE_DR_MOVE
	UpTogi2,	// STATE_U_TOGI
	DownTogi2,	// STATE_D_TOGI
	LeftTogi2,	// STATE_L_TOGI
	RightTogi2	// STATE_R_TOGI
};

#define	PI_PER8			((double)M_PI/(double)8)
double	SinPiPer8Times3;
double	SinPiPer8;

CGFloat randBetween(CGFloat lower, CGFloat upper);

#define RAND ((CGFloat)rand()/(CGFloat)RAND_MAX)
CGFloat randBetween(CGFloat lower, CGFloat upper)
{
    CGFloat result = 0.0;
    
    if (lower > upper)
    {
        CGFloat temp = 0.0;
        temp = lower; lower = upper; upper = temp;
    }
    result = ((upper - lower) * RAND + lower);
    // printf("upper = %f, lower = %f, result = %f\n",upper,lower,result);
    return result;
}

@implementation NekoView

- TickCount
{
	if ( ++NekoTickCount >= MAX_TICK )
		NekoTickCount = 0;

	if ( NekoTickCount % 2 == 0 )
		if ( NekoStateCount < MAX_TICK )
			NekoStateCount++;

	return self;
}

- SetNekoState: (int) SetValue
{
	NekoTickCount=0;
	NekoStateCount=0;

	NekoState=SetValue;
	return self;
}

- DrawNeko: (CGFloat) DrawIcon
{ 
	NekoLastIcon.origin.x=DrawIcon;

	if (NekoPos.origin.x != NekoLastXY.x || NekoPos.origin.y != NekoLastXY.y)
	{
		static const NSRect zero={ { Space, 0.0 },
			{ (CGFloat)BITMAP_WIDTH, (CGFloat)BITMAP_HEIGHT } };

        [bitmaps compositeToPoint:NekoLastXY fromRect:zero operation:NSCompositeSourceOver];
	}

    [bitmaps compositeToPoint:NekoPos.origin fromRect:NekoLastIcon operation:NSCompositeSourceOver];

	NekoLastXY=NekoPos.origin;
	return self;
}

- NekoDirection
{
	int			NewState;
	double		LargeX, LargeY;
	double		Length;
	double		SinTheta;

	if ( NekoMoveDx == 0 && NekoMoveDy == 0 )
		NewState = STATE_STOP;
	else
	{
	LargeX = (double)NekoMoveDx;
	LargeY = (double)(-NekoMoveDy);
	Length = sqrt( LargeX * LargeX + LargeY * LargeY );
	SinTheta = LargeY / Length;

	if ( NekoMoveDx > 0 )
	{
		if ( SinTheta > SinPiPer8Times3 )
			NewState = STATE_U_MOVE;
		else if ((SinTheta <= SinPiPer8Times3) && (SinTheta > SinPiPer8))
			NewState = STATE_UR_MOVE;
		else if ((SinTheta <= SinPiPer8) && (SinTheta > -(SinPiPer8)))
			NewState = STATE_R_MOVE;
		else if ((SinTheta <= -SinPiPer8) && (SinTheta > -SinPiPer8Times3))
			NewState = STATE_DR_MOVE;
		else
			NewState = STATE_D_MOVE;
	}
	else
	{
		if ( SinTheta > SinPiPer8Times3)
			NewState = STATE_U_MOVE;
		else if ((SinTheta <= SinPiPer8Times3) && (SinTheta > SinPiPer8))
			NewState = STATE_UL_MOVE;
		else if ((SinTheta <= SinPiPer8 ) && (SinTheta > -SinPiPer8))
			NewState = STATE_L_MOVE;
		else if ((SinTheta <= -SinPiPer8) && (SinTheta > -SinPiPer8Times3))
			NewState = STATE_DL_MOVE;
		else
			NewState = STATE_D_MOVE;
	}
	}

	if ( NekoState != NewState )
		[self SetNekoState: NewState];

	return self;
}

- (BOOL) IsNekoDontMove
{
	if ( NekoPos.origin.x == NekoLastXY.x && NekoPos.origin.y == NekoLastXY.y )
		return( YES );

	return( NO );
}

- (BOOL) IsNekoMoveStart
{
	if ( ( PrevMouseX >= MouseX - IDLE_SPACE
			&& PrevMouseX <= MouseX + IDLE_SPACE ) &&
			( PrevMouseY >= MouseY - IDLE_SPACE 
			&& PrevMouseY <= MouseY + IDLE_SPACE ) )
		return( NO );

	return( YES );
}

- CalcDxDy
{
	double	LargeX, LargeY;
	double	DoubleLength, Length;

	if (randCount1 == -100)		// a signal to let values be...
		randCount1 = 200;
	else
	{
  		PrevMouseX = MouseX;
		PrevMouseY = MouseY;
	}

	if (--randCount1 < 0)
	{
        NSRect bounds = [self bounds];
		randCount1 = (random() % (300));
		MouseX = randBetween(-90,bounds.size.width+90);
		MouseY = randBetween(-90,bounds.size.height+90);
	}

	LargeX = (double)( MouseX - NekoPos.origin.x - BITMAP_WIDTH/2 );
	LargeY = (double)( MouseY - NekoPos.origin.y );

	DoubleLength = LargeX * LargeX + LargeY * LargeY;

	if ( DoubleLength != (double)0 )
	{
		Length = sqrt( DoubleLength );
		if ( Length <= NekoSpeed ) {
			NekoMoveDx = (int)LargeX;
			NekoMoveDy = (int)LargeY;
		} else {
			NekoMoveDx = (int)( ( NekoSpeed * LargeX ) / Length );
			NekoMoveDy = (int)( ( NekoSpeed * LargeY ) / Length );
		}
	}
	else NekoMoveDx = NekoMoveDy = 0;

	return self;
}


- oneStep
{
    NSRect bounds = [self bounds];
	usleep(1000000 / 8);	// run at about 8 frames/sec

	[self CalcDxDy];

	if ( NekoState != STATE_SLEEP )
		[self DrawNeko: NekoTickCount % 2 == 0 ?
			Even[NekoState] : Odd[NekoState]];
	else [self DrawNeko: NekoTickCount % 8 <= 3 ?
			Even[NekoState] :Odd[NekoState]];

	[self TickCount];

	switch ( NekoState ) 
	{
	case STATE_STOP:
		if ( [self IsNekoMoveStart])
		{
			[self SetNekoState: STATE_AWAKE ];
			break;
		}
		if ( NekoStateCount < TIME_STOP )
			break;

		if ( NekoMoveDx < 0 && NekoPos.origin.x <= 0 )
			[self SetNekoState: STATE_L_TOGI ];

		else if ( NekoMoveDx > 0 &&
				NekoPos.origin.x >= bounds.size.width - BITMAP_WIDTH )
			[self SetNekoState: STATE_R_TOGI ];

		else if ( NekoMoveDy < 0 && NekoPos.origin.y <= 0 )
			[self SetNekoState: STATE_U_TOGI ];

		else if ( NekoMoveDy > 0 && NekoPos.origin.y >=
				bounds.size.height - BITMAP_HEIGHT )
			[self SetNekoState: STATE_D_TOGI ];

		else [self SetNekoState: STATE_JARE ];

		break;

	case STATE_JARE:
		if ( [self IsNekoMoveStart] )
		{
			[self SetNekoState: STATE_AWAKE ];
			break;
		}
		if ( NekoStateCount < TIME_JARE )
			break;

		[self SetNekoState: STATE_KAKI ];
		break;

	case STATE_KAKI:
		if ( [self IsNekoMoveStart])
		{
			[self SetNekoState: STATE_AWAKE ];
			break;
		}
		if ( NekoStateCount < TIME_KAKI )
			break;

		[self SetNekoState: STATE_AKUBI ];
		break;

	case STATE_AKUBI:
		if ( [self IsNekoMoveStart] )
		{
			[self SetNekoState: STATE_AWAKE ];
			break;
		}
		if ( NekoStateCount < TIME_AKUBI )
			break;

		[self SetNekoState: STATE_SLEEP ];
		break;

	case STATE_SLEEP:
		if ( [self IsNekoMoveStart] )
		{
			[self SetNekoState: STATE_AWAKE ];
			break;
		}
		break;

	case STATE_AWAKE:
		if ( NekoStateCount < TIME_AWAKE )
			break;

		[self NekoDirection];
		break;

	case STATE_U_MOVE:
	case STATE_D_MOVE:
	case STATE_L_MOVE:
	case STATE_R_MOVE:
	case STATE_UL_MOVE:
	case STATE_UR_MOVE:
	case STATE_DL_MOVE:
	case STATE_DR_MOVE:
		NekoPos.origin.x += NekoMoveDx;
		NekoPos.origin.y += NekoMoveDy;
		[self NekoDirection];
		[self NekoAdjust];

		if ( [self IsNekoDontMove])
			[self SetNekoState: STATE_STOP ];

		break;

	case STATE_U_TOGI:
	case STATE_D_TOGI:
	case STATE_L_TOGI:
	case STATE_R_TOGI:
		if ( [self IsNekoMoveStart] )
		{
			[self SetNekoState: STATE_AWAKE ];
			break;
		}
		if ( NekoStateCount < TIME_TOGI )
			break;

		[self SetNekoState: STATE_KAKI ];
		break;

	default:
		/* Internal Error */
		[self SetNekoState: STATE_STOP ];
		break;
	}

	return self;
}

- NekoAdjust
{
    NSRect bounds = [self bounds];
	if ( NekoPos.origin.x < 0 )
		NekoPos.origin.x = 0;
	else if ( NekoPos.origin.x > bounds.size.width - BITMAP_WIDTH )
		NekoPos.origin.x = bounds.size.width - BITMAP_WIDTH;

	if ( NekoPos.origin.y < 0 )
		NekoPos.origin.y = 0;
	else if ( NekoPos.origin.y > bounds.size.height - BITMAP_HEIGHT )
		NekoPos.origin.y = bounds.size.height - BITMAP_HEIGHT;

	return self;
}

- setBitmaps:anObject
{
	bitmaps = anObject;
	return self;
}

- bitmaps
{
	return bitmaps;
}

- (id)initWithFrame:(NSRect)frameRect
{
	SinPiPer8Times3=sin(PI_PER8*(double)3);
	SinPiPer8=sin(PI_PER8);

	self = [super initWithFrame:frameRect];
    if(self)
    {
        // [self setClipping:NO];
        [self allocateGState];
        
        NekoPos = NSMakeRect((frameRect.size.width-(BITMAP_WIDTH/2))/2.0,
                             (frameRect.size.height-(BITMAP_HEIGHT/2))/2.0,
                             BITMAP_WIDTH, BITMAP_HEIGHT);
        NekoLastXY = NekoPos.origin;
        
        bitmaps=[self findImageNamed:@"browncat"];
        
        NekoLastIcon = NSMakeRect( Even[STATE_STOP], 0.0,
                  (CGFloat)BITMAP_WIDTH, (CGFloat)BITMAP_HEIGHT);
        NekoSpeed=14;
        [self SetNekoState: STATE_STOP];
        randCount1 = 100;
    }
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	PSsetgray(0);
	NSRectFill(dirtyRect);
    
    [bitmaps compositeToPoint:NekoPos.origin fromRect:NekoLastIcon
                    operation:NSCompositeSourceOver];
}

/*
- sizeTo:(NXCoord)width :(NXCoord)height
{
	[super sizeTo:width:height];
	[self NekoAdjust];
	return self;
}
*/

- (NSString *) windowTitle
{
    return @"Neko";
}

/*
- inspector:sender
{
	char buf[MAXPATHLEN];
	
	if (!inspectorPanel)
	{
		sprintf(buf,"%s/Neko.nib",[sender moduleDirectory:"Neko"]);
		[NXApp loadNibFile:buf owner:self withNames:NO];
	}
	return inspectorPanel;
}
*/

- (BOOL) useBufferedWindow
{	return YES;
}

- (NSImage *)findImageNamed:(NSString *)name
{
	id ret = [NSImage imageNamed: name];
	return ret;
}

- inspectorWillBeRemoved
{
	[infoWindow orderOut:self];
	return self;
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint loc = [event locationInWindow];
    [self convertPoint:loc fromView:nil];
	randCount1 = -100;
  	PrevMouseX = MouseX;
	PrevMouseY = MouseY;
	MouseX = loc.x;
	MouseY = loc.y;
}


@end
