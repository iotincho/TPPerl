#!/usr/local/bin/perl
use lib '.';
use LWP::Simple;
use funciones;
use Excel::Writer::XLSX;


#============================================================================#
#====================   CONFIGURA UNAS OPCIONES PARA EXEL  ==================#
#============================================================================#

# Create a new Excel workbook
my $workbook = Excel::Writer::XLSX->new('perl.xls');
# Add a worksheet
$worksheet = $workbook->add_worksheet('por seccion');
#  Add and define a format
$format = $workbook->add_format(); # Add a format
$format->set_bold();
$format->set_color('green');
$format->set_align('center');

$format_total = $workbook->add_format(); # Add a format
$format_total->set_bold();
$format_total->set_color('blue');
$format_total->set_align('rigth');
$format_total->set_bg_color('silver');
$format_total->set_border_color('black');
# Write a formatted and unformatted string, row and column notation.
$format_porc = $workbook->add_format(); # Add a format
$format_porc->set_num_format(0x0a); #formato porcentual

$row = 0;

#=======================================================================#
#====================   EXTRAE LOS DATOS POR SECCION  ==================#
#=======================================================================#
my %secciones = secciones();

my @partidos = ("UNION.POR.CORDOBA",
            "MST.NUEVA.IZQUIERDA",
            "MOVIMIENTO.AL.SOCIALISMO",
            "FRENTE.PROGRESISTA.Y.POPULAR",
            "FRENTE.DE.IZQUIERDA.Y.DE.LOS.TRABAJADORES",
            "CORDOBA.PODEMOS",
            "JUNTOS.POR.CORDOBA",
            "NULOS",
            "BLANCOS");

my %votos_secciones=votos_por_seccion(\%secciones,\@partidos);

 ## escribe los datos en exel
foreach my $i (sort{$a<=>$b}(keys %votos_secciones)){
  next if $i eq 'TOTAL';
#  print "\nseccion : $i -> $secciones{$i}\n"; # impresion para consola
  $worksheet->write($row, 0, "$secciones{$i}", $format); #pone la etiqueta de la seccion en exel
  $row++;
  foreach my $j (keys %{$votos_secciones{$i}}){
#    print "     $j ->  $votos_secciones{$i}{$j}\n"; # impresion del partido y los votos para consola
    $worksheet->write($row,1, "$j"); #escribe el nombre del partido
    $worksheet->write($row,2, "$votos_secciones{$i}{$j}"); # escribe la ctidad de votos que le corresponde en la siguiente celda
    $worksheet->write($row,3,
                      $votos_secciones{$i}{$j}/$votos_secciones{$i}{'VALIDOS'},
                      $format_porc) if $j ne 'BLANCOS' and $j ne 'NULOS' and $j ne 'VALIDOS';
    $row++;
  }
}

#escribe la seccion de total.
$row = 1;
$worksheet->write(0,5, "TOTAL",$format_total); #crea la etiquete para el total
print "\nTOTAL:\n";
foreach my $j (keys %{$votos_secciones{'TOTAL'}}){
  print "     $j ->  $votos_secciones{'TOTAL'}{$j}\n"; # impresion del partido y los votos para consola
  $worksheet->write($row,5, "$j",$format_total); #nombre del partido
  $worksheet->write($row,6, "$votos_secciones{'TOTAL'}{$j}",$format_total); #cantidad de votos
  $worksheet->write($row,7,
                    $votos_secciones{'TOTAL'}{$j}/$votos_secciones{'TOTAL'}{'VALIDOS'},  #porcentaje de votos
                    $format_porc) if $j ne 'BLANCOS' and $j ne 'NULOS' and $j ne 'VALIDOS';
  $row++;
}


#=======================================================================#
#====================   EXTRAE LOS DATOS POR CIRCUITO  ==================#
#=======================================================================#

my %circuitos_por_seccion = circuitos_por_secciones();
my %resultados_por_circuito = votos_por_circuito(\%circuitos_por_seccion,\@partidos);


#ahora escribe en exel
$row = 0;
$worksheet = $workbook->add_worksheet('por_circuito');
for my $sec(sort {$a<=>$b} (keys %resultados_por_circuito)){ #clasifica por circuito
  next if $sec eq 'TOTAL';
  print "$sec\n";
  $worksheet->write($row, 0, "$secciones{$sec}", $format); #pone la etiqueta de la seccion en exel
  $row++;
  for my $circ (keys %{$resultados_por_circuito{$sec}}){ #itera entre circuitos
    print "    $circ\n";
    $worksheet->write($row, 1, "$circuitos_por_seccion{$sec}{$circ}", $format); #pone la etiqueta de circuito en exel
    $row++;
    for my $part (keys %{$resultados_por_circuito{$sec}{$circ}}){ #itera entre los partidos de cada circuito
      print "            $part   $resultados_por_circuito{$sec}{$circ}{$part}\n";
      $worksheet->write($row,2, "$part"); #escribe el nombre del partido
      $worksheet->write($row,3, "$resultados_por_circuito{$sec}{$circ}{$part}"); # escribe la ctidad de votos que le corresponde en la siguiente celda
      $worksheet->write($row,4,
                        $resultados_por_circuito{$sec}{$circ}{$part}/$resultados_por_circuito{$sec}{$circ}{'VALIDOS'},
                        $format_porc) if $part ne 'BLANCOS' and $part ne 'NULOS' and $part ne 'VALIDOS' and $resultados_por_circuito{$sec}{$circ}{'VALIDOS'} != 0;
      $row++;
    }
  }
}
#escribe la seccion de total
$row = 1;
$worksheet->write(0,5, "TOTAL",$format_total); #crea la etiquete para el total
print "\nTOTAL:\n";
foreach my $part (keys %{$resultados_por_circuito{'TOTAL'}{'TOTAL'}}){
  print "     $part ->  $resultados_por_circuito{'TOTAL'}{'TOTAL'}{$part}\n"; # impresion del partido y los votos para consola
  $worksheet->write($row,6, "$part",$format_total);
  $worksheet->write($row,7, "$resultados_por_circuito{'TOTAL'}{'TOTAL'}{$part}",$format_total);
  $worksheet->write($row,8,
                    $resultados_por_circuito{'TOTAL'}{'TOTAL'}{$part}/$resultados_por_circuito{'TOTAL'}{'TOTAL'}{'VALIDOS'},
                    $format_porc) if $part ne 'BLANCOS' and $part ne 'NULOS' and $part ne 'VALIDOS' and $resultados_por_circuito{'TOTAL'}{'TOTAL'}{'VALIDOS'} != 0;
  $row++;
}



$workbook->close();
exit;
