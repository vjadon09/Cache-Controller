
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name project1 -dir "/home/student2/asazeez/COE758/project/project1/planAhead_run_1" -part xc3s500efg320-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/student2/asazeez/COE758/project/project1/cache_controller.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/student2/asazeez/COE758/project/project1} {ipcore_dir} }
add_files [list {ipcore_dir/icon.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/ila.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/vio.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "cache.ucf" [current_fileset -constrset]
add_files [list {cache.ucf}] -fileset [get_property constrset [current_run]]
open_netlist_design
