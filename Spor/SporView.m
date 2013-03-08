
#import <stdio.h>
#import "SporView.h"
#import "sporen6.h"

#import "PSOperators.h"

#define		MAX_POP			2000
#define 	START_POP		20
#define 	START_SPREAD		10
#define 	START_CLOUD		10	
#define 	START_KIND		 0
#define 	ENEMY			 0

@implementation SporView

- toggleKind:sender
{
  kind = [ [ sender selectedCell ] tag ];

  return self;
}

- toggleEnemy:sender
{
  enemy = [ [ sender selectedCell ] tag ];

  return self;
}

- showStartParameter
{
  char	valueString[ 50 ];
  
  if( inspectorPresent == NO )
    return self;
  
  [ maxPop setDoubleValue: pop ];
  [ startPop setDoubleValue: sPop ];
  [ startSpread setDoubleValue: spread ];
  [ startCloud setDoubleValue: cloud ];
  [ kindRadio selectCellWithTag: (int) kind ];
  [ eatRadio selectCellWithTag: (int) enemy ];
  
  sprintf( valueString, "%ld", (long)pop );
  // NXWriteDefault( "BackSpace", "SporMaxPopulation", valueString );
  sprintf( valueString, "%ld", (long)sPop );
  // NXWriteDefault( "BackSpace", "SporSporStartPopulation", valueString );
  sprintf( valueString, "%ld", (long)spread );
  // NXWriteDefault( "BackSpace", "SporStartSpread", valueString );
  sprintf( valueString, "%ld", (long)cloud );
  // NXWriteDefault( "BackSpace", "SporStartCloud", valueString );
  sprintf( valueString, "%ld", (long)kind );
  // NXWriteDefault( "BackSpace", "SporStartKind", valueString );
  sprintf( valueString, "%ld", (long)enemy );
  // NXWriteDefault( "BackSpace", "SporEnemyMode", valueString );
  
  return self;
}

- getStartParameter
{ 
  if( inspectorPresent == NO )
    return self;
  
  pop = [ maxPop intValue ];
  pop = [ self setRangeForValue:pop Low:200 High:50000 ];
  sPop = [ startPop intValue ];
  sPop = [ self setRangeForValue: sPop Low:3 High:200 ];	
  spread = [ startSpread intValue ];
  spread = [ self setRangeForValue:spread Low:5 High:100 ];
  cloud = [ startCloud intValue ];
  cloud = [ self setRangeForValue:cloud Low:5 High:100 ];
  
  return self;
}

- ( NSInteger )setRangeForValue:( NSInteger )aValue Low:( NSInteger )low High:( NSInteger )high
{
  if( aValue > high )
    aValue = high;
  if( aValue < low )
    aValue = low;
  
  return( aValue );
}

- (void)setFrame: (NSRect) frame
{
#ifdef DEBUG
  fprintf( stderr, "sizeTo::\n" );
#endif
  initDone = NO;
  [super setFrame: frame];
}

- initWithFrame: ( NSRect )frameRect
{
  const char *aDefault = 0;
  
  [ super initWithFrame: frameRect ];
  
#ifdef DEBUG
  fprintf( stderr, "\ninitFrame:\n" );
#endif
  
  // aDefault = NXReadDefault( "BackSpace", "SporMaxPopulation" );
  if( !aDefault )
    pop = MAX_POP;
  else
    pop = atoi( aDefault );
  
  // // aDefault = NXReadDefault( "BackSpace", "SporStartPopulation" );
  if( !aDefault )
    sPop = START_POP;
  else
    sPop = atoi( aDefault );
  
  // aDefault = NXReadDefault( "BackSpace", "SporStartSpread" );
  if( !aDefault )
    spread = START_SPREAD;
  else
    spread = atoi( aDefault );
  
  // aDefault = NXReadDefault( "BackSpace", "SporStartCloud" );
  if( !aDefault )
    cloud = START_CLOUD;
  else
    cloud = atoi( aDefault );
  
  // aDefault = NXReadDefault( "BackSpace", "SporStartKind" );
  if( !aDefault )
    kind = START_KIND;
  else
    kind = atoi( aDefault );
  
  // aDefault = NXReadDefault( "BackSpace", "SporEnemyMode" );
  if( !aDefault )
    enemy = ENEMY;
  else
    enemy = atoi( aDefault );
  
  initDone = NO;
  inspectorPresent = NO;	
  
  return self;
}

- drawRect: (NSRect)rect 
{
  int    height,width;
  
#ifdef DEBUG
  fprintf( stderr, "drawSelf::\n" );
#endif
  
  if( initDone == NO )
    {
      height = ( int )rect.size.height;
      width = ( int )rect.size.width;
      set_screen_size( width, height, width );
      [self getStartParameter];
      [self showStartParameter];

      set_simulation_parameter( pop, sPop, spread, kind, cloud, (int)enemy );
      init_sim();
      
      initDone = YES;
    }
  else
    {
      PSsetgray( 0 );
      NSRectFill( rect );
    }
  
  return self;
}

- oneStep
{
  cDoSimulation();
  return self;
}

- (id)inspector: (id)sender
{
  if( !inspector )
    {
      if([NSBundle loadNibNamed: @"SporView" owner:self] == NO)
	{
	  NSLog(@"Failed to load");
	}
    }
  return inspector;
}

- inspectorInstalled
{
  inspectorPresent = YES;	
  [ self showStartParameter ];
  return self;
}

- inspectorWillBeRemoved
{
  [ sporWindow close ];
  return self;
}

@end
