#!/usr/local/bin/perl

use LWP::Simple;
use funciones;
use LWP::Simple;

my $html;

$html = get 'https://www.justiciacordoba.gob.ar/jel/ReportesEleccion20150705/Index.html'; # pagina principal para obtener las claves
$html =~ s/\n/ /g;
$html =~ /(<script.*<\/script>)/;
$html = $1;
$html =~ s/\);/\);\n/g;

my %secciones_aux = secciones();
#foreach my $i (keys %secciones_aux){
#  print "$i -> $secciones_aux{$i}\n";
#}

my %secciones;
foreach my $k (keys %secciones_aux){
  $html =~ /arrCircuitosSecc$k.*\((.*)\);\n/;
  my $arrCircuitosSeccx = $1;
  my @aux = split (/,/,$arrCircuitosSeccx);
  my %circuitos;
  foreach my $i (@aux){
    $i =~ /["']([^|]*)|.*/g; #parseo de la linea. no s porque no puedo extraerlos a los dos juntos con $1 y $2
    my $i1= $1;
    $i=~ /;(.*)["']/;
    #$circuitos{$i1} = $1;#agrego la entrada al hash
    $secciones{$k}{$i1} = $1 #agrego la entrada al hash agruapando por secciones
  }
}

foreach my $i (keys %secciones){
  print "$secciones_aux{$i}\n";
  foreach my $j (keys %{$secciones{$i}}){
    print "     $j ->  $secciones{$i}{$j}\n"; # impresion del partido y los votos para consola
  }
}


#  for $i (keys %circuitos){
#  print "$i -> $circuitos{$i}\n";
#  }
