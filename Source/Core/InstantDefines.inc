{$IFDEF VER130}
{$DEFINE D5}
{$ENDIF}

{$IFDEF VER140}
{$DEFINE D6}
{$ENDIF}

{$IFDEF VER150}
{$DEFINE D7}
{$ENDIF}

{$IFNDEF VER130}
  {$DEFINE D6+}
  {$IFNDEF VER140}
    {$DEFINE D7+}
  {$ENDIF}
{$ENDIF}