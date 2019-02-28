#!/usr/local/bin/perl
package funciones;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(secciones votos_por_seccion circuitos_por_secciones votos_por_circuito);

$basic_url='https://www.justiciacordoba.gob.ar/Estatico/JEL/Escrutinios/ReportesEleccion20150705/';

sub trim { #elimina los espacios al inicio y al final.
 my $string = shift;
 $string =~ s/^\s+|\s+$//;
# $string =~ s/^\s+//;
# $string =~ s/\s+$//;
 return $string;
}

sub secciones{
  use LWP::Simple;
  my $html;
  my $secciones_html;
  my %secciones;
  $html = get $basic_url.'Index.html'; # pagina principal para obtener las claves
  #$html =~ /(<.*LocalidadesTodos.*<\/select>)/; # filtra el html para obtener las localidades y sus codigos
  $html =~ /(<.*cmbSecciones.*<\/select>)/;
  $secciones_html = $1;
  $secciones_html =~ s/<\/OPTION>/<\/OPTION>\n/g; # acomoda los tags con saltos de linea
  for my $line (split /\n/, $secciones_html){
      #print $line, "\n";
      if($line =~ /<OPTION value="(\d*)\|\d*">(.*)<\/OPTION>/g){ # toma los valores que se buscan 'Codigo' => 'localidad'
       $secciones{trim $1} = $2;
      }
  }
#  for my $k(keys %localidades){
#      print "$k   $localidades{$k}\n";
#  }
  return %secciones;
}

sub circuitos_por_secciones{
  use LWP::Simple;

  my $html;

  $html = get $basic_url.'Index.html'; # pagina principal para obtener las claves
  $html =~ s/\n/ /g; #elimina los saltos de linea
  $html =~ /(<script.*<\/script>)/; # filtra la seccion del scrip de donde se van a obtener los datos
  $html = $1;
  $html =~ s/\);/\);\n/g; #agrega saltos de linea al final de las lineas para facilitar el parseo

  my %secciones_aux = secciones(); # busca las secciones que existen para asociar los circuitos
  my %secciones;
  foreach my $k (keys %secciones_aux){ #obtendra los circuitos para cada seccion
    $html =~ /arrCircuitosSecc$k.*\((.*)\);\n/; #$k es el numero de seccion al nombre del array es el que esta en el javascript
    my $arrCircuitosSeccx = $1;
    my @aux = split (/,/,$arrCircuitosSeccx); #se fracciona en las componeentes del array
    my %circuitos;
    foreach my $i (@aux){ # cada linea contiene un par (codigo-de-circuito, nombre-del-circuito)
      $i =~ /["']([^|]*)|.*/g; #parseo de la linea. no se porque no puedo extraerlos a los dos juntos con $1 y $2
      my $i1= $1;
      $i=~ /;(.*)["']/;
      $secciones{$k}{trim $i1} = $1 #agrego la entrada al hash agruapando por secciones, el valor del hash es el nombre del circuito.
    }
  }

#imprime logs de prueva para ver que haya quedado bien el hash seccion->codigo-codigo-de-circuito->circuito
#  foreach my $i (keys %secciones){
#    print "$secciones_aux{$i}\n";
#    foreach my $j (keys %{$secciones{$i}}){
#      print "     $j ->  $secciones{$i}{$j}\n"; # impresion del partido y los votos para consola
#    }
#  }
return %secciones;
}

sub votos_por_seccion{
  my %secciones = %{$_[0]};
  my @partidos = @{$_[1]};
#  foreach my $k(sort {$a<=>$b}(keys %secciones)){
#        print "$k=>$secciones{$k}\n";
#  }
#  foreach my $i(@partidos){
#    print "$i\n";
#  }
  my %votos_por_seccion;
  my $html;
  foreach my $code (keys %secciones){ # va a pedir una pagina por cada seccion
    print "$code->$secciones{$code}\n";
    my $url = $basic_url."Resultados/E20150705_S".$code."_CA2_0.htm";
    #print "$url\n";
    $html = get $url;
    $html =~ s/\n|\r//g; # elimina los saltos de linea
    $html =~ s/<\/TR>\s*/<\/TR>\n/g;# crea separa las filas de la tabla con un salto de linea
    my $aux;
    my $votos_validos = 0;

    foreach my $i(split('\n',$html)){ # filtrara cada linea de la tabla
      foreach my $partido (@partidos){  # comprueba si la linea de tabla concuerda con algun partido
        if($i =~ /(<.*$partido.*)/){
           $aux = $1;
           $aux =~ s/<[^>]*>//g; # elimina los tags html
           $aux =~ s/\s+/ /g; # elimina los espacios multiples
           print $aux."\n";
           my @line = split(/[\s$partido]+/,$aux); # parsea la linea
           $line[-1] =~ s/,//g; #elimina la ',' de mil que aparece por defecto en el html
           $votos_por_seccion{$code}{$partido} = 0+$line[-1];
           $votos_por_seccion{'TOTAL'}{$partido} += $line[-1];
           $votos_validos += $line[-1] if(($partido ne 'BLANCOS') and ($partido ne 'NULOS')); # cuenta los votos validos
           #print "@line\n";
           last;
        }
      }
    }
    $votos_por_seccion{$code}{'VALIDOS'}=$votos_validos;  #carga todos los validos de esa seccion
    $votos_por_seccion{'TOTAL'}{'VALIDOS'}+=$votos_validos;
    #print "$_ $resultado{$_}\n" for (keys %resultado);
    #print "\n";
  }
  return %votos_por_seccion
}

sub votos_por_circuito{
  my %circuitos_por_seccion = %{$_[0]};
  my @partidos = @{$_[1]};
#  foreach my $k(sort {$a<=>$b}(keys %secciones)){
#        print "$k=>$secciones{$k}\n";
#  }
#  foreach my $i(@partidos){
#    print "$i\n";
#  }

  my %votos_por_circuito;
  my $html;
  foreach my $sec (keys %circuitos_por_seccion){ # debe tomar todos los circuitos por seccion
    my %circuitos = %{$circuitos_por_seccion{$sec}};
    foreach my $circ (keys %circuitos){ # va a pedir una pagina por cada circuito
      print "$circ->$circuitos{$circ}\n";
      my $url = $basic_url."Resultados/E20150705_C".$circ."_CA2_0.htm";
      #print "$url\n";
      $html = get $url;
      $html =~ s/\n|\r//g; # elimina los saltos de linea
      $html =~ s/<\/TR>\s*/<\/TR>\n/g;# crea separa las filas de la tabla con un salto de linea
      my $aux;
      my $votos_validos = 0;
      foreach my $i(split('\n',$html)){ # filtrara cada linea de la tabla
        foreach my $partido (@partidos){  # comprueba si la linea de tabla concuerda con algun partido
          if($i =~ /(<.*$partido.*)/){
             $aux = $1;
             $aux =~ s/<[^>]*>//g; # elimina los tags html
             $aux =~ s/\s+/ /g; # elimina los espacios multiples
             print $aux."\n";
             my @line = split(/[\s$partido]+/,$aux); # parsea la linea
             $line[-1] =~ s/,//g; #elimina la ',' de mil que aparece por defecto en el html
             $votos_por_circuito{$sec}{$circ}{$partido} = 0+$line[-1];
             $votos_por_circuito{'TOTAL'}{'TOTAL'}{$partido} += $line[-1];
             $votos_validos += $line[-1] if(($partido ne 'BLANCOS') and ($partido ne 'NULOS'));
             #print "@line\n";
             last;
          }
        }
      }
      $votos_por_circuito{$sec}{$circ}{'VALIDOS'}=$votos_validos;  #carga todos los validos de esa seccion
      $votos_por_circuito{'TOTAL'}{'TOTAL'}{'VALIDOS'}+=$votos_validos;
    }
  }
  return %votos_por_circuito
}
