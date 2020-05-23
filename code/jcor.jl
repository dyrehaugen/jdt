# ~/zjul/corona/wrld/jmh/src/jcor.jl  - Grand Loop Version from 006    
# 200424 007
# 
#
using CSV, DataFrames, Dates, Printf, Plots

# Specify which countries to extract and give population in millions:
# (from: https://www.worldometers.info/world-population/population-by-country/)
clist  = ["Argentina" "Belgium" "Brazil" "Norway" "Panama" "Spain" "Sweden" "Thailand"]
plist  = [45.195774,  11.589623, 212.559417, 5.421241,4.314767, 46.754778, 10.099265, 67.799978]

# Select which data source to read: cfm, dth or rcv
data = "dth"    #"dth" # "rcv" #  "dth" "cfm"

# Grand Loop:
for data in ["cfm" "dth" "rcv"]
    println("running jcor: ", data, "...")
    # end  # at EOF
    
    if length(ARGS) >= 1 data=ARGS[1] end  # Command line selection
    if data == "cfm" 
        df_dta_src = CSV.read("../data/confirmed.csv")
        th = 100; ths="100";
        plotstring="Confirmed Cases";
    elseif data == "rcv"
        df_dta_src = CSV.read("../data/recovered.csv")
        th = 30; ths="30";  # Error in data for Norway end on 32
        plotstring="Recovered";    
    elseif  data == "dth"
        df_dta_src = CSV.read("../data/deaths.csv")
        th = 10; ths="10";
        plotstring="Deaths";    
    else
        println("Incorrect data selection: should be one of: cfm dth rcv")
        #@goto EOF  # readline()
    end
    
    countries = df_dta_src[:,2]
    lastdate = String(names(df_dta_src)[end])
    
    
    # Extracting the epidemic data:
    cindx = Array{Int64}(undef, length(clist))
    dta   = zeros(size(df_dta_src)[2]-4, length(clist)); # Data starts in column 4
    for i in 1:length(clist)
        indx = findall(x->x==clist[i], df_dta_src[:,2])
        dta[:,i] = convert(Array, df_dta_src[indx,5:end])
    end
    df_dta = DataFrame(dta)
    for i in 1:length(clist)
         rename!(df_dta, names(df_dta)[i] => Symbol(clist[i]));
    end
    
    # Converting the Dates:
    colstring = Array{Union{Nothing, String}}(nothing, length(names(df_dta_src))-4,2)
    coldates  = Array{Date,length(names(df_dta_src))-4}
    for i in 1:length(names(df_dta_src))-4 colstring[i,1] = String(names(df_dta_src)[i+4])*"20" end #  adding 20 to get 2020     
    colstring2=colstring
    for i=1:length(colstring[:,1]) colstring2[i,1]=replace(colstring[i,1], "/" => "-") end
    coldates=Date.(colstring2[:,1], Dates.DateFormat("mm-dd-yyyy"))
    df_00 = DataFrame([coldates])
    rename!(df_00, :x1 => :Date)
    CSV.write("dfs/df_00.csv", df_00)
    
    
    # Joining Dates and Data:                                                                                                    
    df_dta = hcat(df_00, df_dta)
    CSV.write("dfs/df_"*data*".csv", df_dta)
    
    # Finding first occurrence of more than 'th' confirmed cases
    firsts = zeros(Int, size(df_dta)[2]-1)
    for j in 1:size(df_dta)[2]-1 firsts[j] = findfirst(x->x>th, dta[:,j]) end
    
    # Extracting above threshold data:
    mtx = Array{Union{Missing, Float64}}(missing,size(df_dta)[1]-minimum(firsts)+1, size(df_dta)[2]-1)
    for j in 1:size(mtx)[2]
        for i in 1:size(dta)[1]-firsts[j]+1   mtx[i,j] = dta[firsts[j]-1+i,j] end
    end
    df_dta_th = DataFrame(mtx)
    for i in 1:length(clist)
         rename!(df_dta_th, names(df_dta_th)[i] => Symbol(clist[i]));
    end
    CSV.write("dfs/df_"*data*"_"*ths*".csv", df_dta_th)
    
    # Per Million inhabitants:
    mtx2 = copy(mtx)
    for j in 1:length(clist) mtx2[:,j] = mtx2[:,j]./plist[j] end
    df_dta_thm = DataFrame(mtx2)
    for i in 1:length(clist)
        rename!(df_dta_thm, names(df_dta_thm)[i] => Symbol(clist[i]));
    end
    CSV.write("dfs/df_"*data*"_"*ths*"m.csv", df_dta_thm)
    
    
    # PLOTTING:
    updated = @sprintf "%10s" df_dta.Date[end]
    
    plot(df_dta[:,1], dta,
         label = clist,
         legend=:outertopright, xrotation=45,
         xlabel = "End of data: "*updated, xguidefontsize=8,
         title = "Corona 2020\n(1)"*plotstring*" - Selected Countries")
    savefig("figs/"*data*"_01.png")
    
    labels1 = String[]
    for i in 2:length(names(df_dta)) push!(labels1, String(names(df_dta)[i])) end
    labels = reshape(labels1,1,:)
    nmlast = [findfirst( x-> ismissing(x), mtx[:,i]) for i in 1:size(mtx)[2]]
    for i in 1:length(nmlast)
        if nmlast[i] == nothing
            nmlast[i] = size(mtx,1)
        else
            nmlast[i]= nmlast[i] - 1
        end
    end
    
    plot(mtx, yaxis=:log,
         label = clist,
         legend=:outertopright, xrotation=45,
         ylabel = "Logaritmic Scale", xguidefontsize=8,
         xlabel = "Days since first "*ths*" cases\nEnd of data: "*updated,     
         annotations=([(nmlast[i], mtx[nmlast[i],i],text(labels[i][1:2], :left, 8)) for i in 1:length(nmlast)]),
         title  = "Corona 2020\n(2)"*plotstring*" - Selected Countries")
    savefig("figs/"*data*"_02.png")
    
    plot(mtx2,
         label = clist,
         legend=:outertopright, xrotation=45,
         xlabel="Days since first "*ths*" cases\nEnd of data: "*updated, xguidefontsize=8,
         annotations=([(nmlast[i], mtx2[nmlast[i],i],text(labels[i][1:2], :left, 8)) for i in 1:length(nmlast)]),
         title = "Corona 2020\n(3)"*plotstring*" per Million Population\nSelected Countries")
    savefig("figs/"*data*"_03.png")
    
end # Grand Loop 


# @label EOF
# EOF
