$c = Get-Content -Raw 'c:\Users\AM\Documents\GitHub\binary-editor.html'
$s=$c.IndexOf('<script>'); $e=$c.IndexOf('</script>')
$js=$c.Substring($s+8,$e-$s-8)
$n=$js.Length; $i=0; $state='code'
$balB=0;$balP=0;$minB=0;$minP=0
$lineNo=1
$reportB=@(); $reportP=@()
while($i -lt $n){
 $ch=[string]$js[$i]
 $nxt= if($i+1 -lt $n){[string]$js[$i+1]}else{''}
 if($ch -eq "`n"){$lineNo++}
 if($state -eq 'code'){
  if($ch -eq '/' -and $nxt -eq '/'){ $state='line'; $i+=2; continue }
  if($ch -eq '/' -and $nxt -eq '*'){ $state='block'; $i+=2; continue }
  if($ch -eq "'"){$state='s'}
  elseif($ch -eq '"'){$state='d'}
  elseif($ch -eq '`'){$state='t'}
  elseif($ch -eq '('){$balP++}
  elseif($ch -eq ')'){$balP--; if($balP -lt $minP){$minP=$balP; $reportP += "line ${lineNo} balP ${balP}"}}
  elseif($ch -eq '{'){$balB++}
  elseif($ch -eq '}'){$balB--; if($balB -lt $minB){$minB=$balB; $reportB += "line ${lineNo} balB ${balB}"}}
 }
 elseif($state -eq 'line'){ if($ch -eq "`n"){$state='code'} }
 elseif($state -eq 'block'){ if($ch -eq '*' -and $nxt -eq '/'){ $state='code'; $i++ } }
 elseif($state -eq 's'){ if($ch -eq '\'){$i++} elseif($ch -eq "'"){$state='code'} }
 elseif($state -eq 'd'){ if($ch -eq '\'){$i++} elseif($ch -eq '"'){$state='code'} }
 elseif($state -eq 't'){ if($ch -eq '\'){$i++} elseif($ch -eq '`'){$state='code'} }
 $i++
}
"final: brace bal=$balB  paren bal=$balP  (relative JS lines; file line = +$([math]::Min($s,0)))"
"brace new-mins: $($reportB -join ' | ')"
"paren new-mins: $($reportP -join ' | ')"
"final state: $state"

