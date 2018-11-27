#!/usr/local/bin/perl
use LWP::Simple;
my %partidos = ("UNION.POR.CORDOBA" => 0,
            "MST.NUEVA.IZQUIERDA" => 0,
            "MOVIMIENTO.AL.SOCIALISMO" => 0,
            "FRENTE.PROGRESISTA.Y.POPULAR" => 0,
            "FRENTE.DE.IZQUIERDA.Y.DE.LOS.TRABAJADORES" => 0,
            "CORDOBA.PODEMOS" => 0,
            "JUNTOS.POR.CORDOBA" => 0);
my $html;
$html = get 'https://www.justiciacordoba.gob.ar/jel/ReportesEleccion20150705/Resultados/E20150705_L387_CA2_0.htm';
$html =~ s/\n|\r//g; # elimina los saltos de linea
$html =~ s/<\/TR>\s*/<\/TR>\n/g;# crea separa las filas de la tabla con un salto de linea
my $mal;
foreach my $i(split('\n',$html)){ # filtrara cada linea de la tabla
  foreach my $exp (keys %partidos){  # comprueba si la linea de tabla concuerda con algun partido
    if($i =~ /(<.*$exp.*)/){
      $mal = $1;
      $mal =~ s/<[^>]*>//g; # elimina los tags html
      $mal =~ s/\s+/ /g; # elimina los espacios multiples
      my @line = split(/[\s$exp]+/,$mal);
      $line[2] =~ s/,//g;
      $partidos{$exp} = $partidos{$exp} + $line[2];
      print "@line\n";
      last;
    }
  }
}

print "$_ $partidos{$_}\n" for (keys %partidos);
#print "@{[%partidos]}\n";
#$mal = $1;

#print $mal;
