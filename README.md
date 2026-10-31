# Lab1

Зиновьев Евгений Андреевич М3О-409Б-23


Добавлен полный функционал. Номер в группе, дата, Первы4 4 буквы фамилии в ASCII коде, первые 4 буквы имени в ASCII коде.

## Запуск (ModelSim)
vlib work
vlog -sv apb_slave.sv apb_master.sv top.sv
vsim work.top
run -all
