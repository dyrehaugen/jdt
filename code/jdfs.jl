# ~/zjul/corona/wrld/jmh/jdfs.jl
# 200504 002
# 002 Glatter df_dcfm_100 Pga.problem med NaNs o jR0.jl
# Read dfs files and make diff dfs

using CSV, DataFrames, Plots
println("Reading data...")
df_00       = CSV.read("dfs/df_00.csv");

df_cfm      = CSV.read("dfs/df_cfm.csv");
df_cfm_100  = CSV.read("dfs/df_cfm_100.csv");
df_cfm_100m = CSV.read("dfs/df_cfm_100m.csv");

df_dth      = CSV.read("dfs/df_dth.csv");
df_dth_10  = CSV.read("dfs/df_dth_10.csv");
df_dth_10m = CSV.read("dfs/df_dth_10m.csv");

df_rcv      = CSV.read("dfs/df_rcv.csv");
df_rcv_30   = CSV.read("dfs/df_rcv_30.csv");
df_rcv_30m  = CSV.read("dfs/df_rcv_30m.csv");

df_R0    = CSV.read("dfs/df_R0.csv");
df_Pred  = CSV.read("dfs/df_Pred.csv");
df_Clow  = CSV.read("dfs/df_Clow.csv");
df_Chgh  = CSV.read("dfs/df_Chgh.csv");
df_Cint  = CSV.read("dfs/df_Cint.csv");



function showframes()
    println()
    println()    
    println("DATAFRAMES AVAILABLE:")
    println()
    println("Confirmed Cases:");
    println("df_cfm        : Per Date");
    println("df_cfm_100    : Per Days since 100 cases");
    println("df_cfm_100m   : Per Days since 100 cases, Per Million Population");
    println("df_dcfm       : Change per Day");    

    println()
    println("Deaths:");
    println("df_dth        : Per Date");
    println("df_dth_10     : Per Days since 10 cases");
    println("df_dth_10m    : Per Days since 10 cases, Per Million Population");
    println("df_ddth       : Change per Day");    
    println()
    
    println("Recovered:");
    println("df_rcv        : Per Date");
    println("df_rcv_30     : Per Days since 30 cases");
    println("df_rcv_30m    : Per Days since 100 cases, Per Million Population");
    println("df_drcv       : Change per Day");    
    println()
    println("R0Analysis:");
    println("df_R0         : Basisc Reproduction Number");
    println("df_Pred       : Epidemic ModelPrediction");
    println("df_Clow       : Confidence Intervall Low");
    println("df_CHgh       : Confidence Intervall High");
    println("df_Cint       : Confidence Intervall Tuple(Low,High)");        
    println()
    println("showframes()  to show this overview")
    println()    
end

showframes()

# CALCULATIONS Differntial Matrices
cfm=Matrix(df_cfm[:,2:end])
dcfm = diff(cfm, dims=1)
df_dcfm = DataFrame(dcfm, names(df_cfm)[2:end])
df_dcfm = hcat(df_00[2:end,:], df_dcfm)
CSV.write("dfs/df_dcfm.csv", df_dcfm)

cfm_100  = Matrix(df_cfm_100)
dcfm_100 = diff(cfm_100, dims=1)
# Glatter for ikke å få 0 som gir NaN i jR0.jl
# Fordeler neste verdi på 2 dager: (Antar ikke 2 dager med0 på rad)
# NB Må unngå brøktall som gir inacacterror i jR0.jl
# 1: Check if zero:
for i = 1:size(dcfm_100)[1]
    for j = 1:size(dcfm_100)[2]-1
        if !ismissing(dcfm_100[i,j])
            if dcfm_100[i,j] == 0.0 && !ismissing(dcfm_100[i+1,j])
                dcfm_100[i,j]   = 0.5*dcfm_100[i+1,j]÷1 
                dcfm_100[i+1,j] = dcfm_100[i,j]+2*(dcfm_100[i+1,j]%1)
            end
         end
    end
end
# 1: Check if negativ: (Norway!)
for i = 1:size(dcfm_100)[1]
    for j = 1:size(dcfm_100)[2]-1
        if !ismissing(dcfm_100[i,j])
            if dcfm_100[i,j] < 0.0 && !ismissing(dcfm_100[i+1,j])
                dcfm_100[i,j]   = 0.5*(dcfm_100[i,j] + dcfm_100[i+1,j])÷1 
                dcfm_100[i+1,j] = dcfm_100[i,j]
            end
         end
    end
end
df_dcfm_100 = DataFrame(dcfm_100, names(df_cfm)[2:end])
CSV.write("dfs/df_dcfm_100.csv", df_dcfm_100)

# Moving average:
n=5
dcfm_100mv= Array{Union{Missing, Float64}}(missing,size(dcfm_100)[1]-(n-1), size(dcfm_100)[2])
vsm(vs,n) = [sum(@view vs[i:(i+n-1)])/n for i in 1:(length(vs)-(n-1))]
for j in 1:size(dcfm_100)[2]
    dcfm_100mv[:,j] = vsm(dcfm_100[:,j],5).÷1
end
df_dcfm_100mv = DataFrame(dcfm_100mv, names(df_cfm)[2:end])
CSV.write("dfs/df_dcfm_100mv.csv", df_dcfm_100mv)


dth=Matrix(df_dth[:,2:end])
ddth = diff(dth, dims=1)
df_ddth = DataFrame(ddth, names(df_dth)[2:end])
df_ddth = hcat(df_00[2:end,:], df_ddth)
CSV.write("dfs/df_ddth.csv", df_ddth)

dth_10  = Matrix(df_dth_10)
ddth_10 = diff(dth_10, dims=1)
df_ddth_10 = DataFrame(ddth_10, names(df_cfm)[2:end])
CSV.write("dfs/df_ddth_10.csv", df_ddth_10)

rcv=Matrix(df_rcv[:,2:end])
drcv = diff(rcv, dims=1)
df_drcv = DataFrame(drcv, names(df_rcv)[2:end])
df_drcv = hcat(df_00[2:end,:], df_drcv)
CSV.write("dfs/df_drcv.csv", df_drcv)

rcv_30  = Matrix(df_rcv_30)
drcv_30 = diff(rcv_30, dims=1)
df_drcv_30 = DataFrame(drcv_30, names(df_cfm)[2:end])
CSV.write("dfs/df_drcv_30.csv", df_drcv_30)


# PLOTTING:
println("Plotting Daily Changes in Confirmed Cases")
for i in 1:size(dcfm,2)
    println(names(df_cfm)[i+1], " ...")
    bar(df_cfm[:,1],dcfm[:,i], xrotation=45, legend=:topleft,
         label = names(df_cfm)[i+1],
         title = "Corona 2020\nDaily Change in Confirmed Cases")
    savefig("figs3/dcfm_"*String(names(df_cfm)[i+1])*".png")
end

println("Plotting Daily Changes in Deaths")
for i in 1:size(ddth,2)
    println(names(df_dth)[i+1], " ...")
    bar(df_dth[:,1],ddth[:,i], xrotation=45, legend=:topleft,
         label = names(df_dth)[i+1],
         title = "Corona 2020\nDaily Change in Deaths")
    savefig("figs4/ddth_"*String(names(df_dth)[i+1])*".png")
end

println("Plotting Daily Changes in Recovered")
for i in 1:size(drcv,2)
    println(names(df_rcv)[i+1], " ...")
    bar(df_rcv[:,1],drcv[:,i], xrotation=45, legend=:topleft,
         label = names(df_rcv)[i+1],
         title = "Corona 2020\nDaily Change in Recovered")
    savefig("figs4/drcv_"*String(names(df_rcv)[i+1])*".png")
end

println("Plotting deaths per million for Norway and Sweden ...")
plot([dropmissing(df_dth_10m, :Norway).Norway,
      dropmissing(df_dth_10m, :Sweden).Sweden],
      legend=:outertopright,
      label = ["Norway" "Sweden"],
      ylabel = "Accumulated Deaths",
      xlabel = "Days since first 10 cases",
      title  = "Corona 2020\n Deaths per Million Population")
savefig("figs2/dth_10m_NoSe.png")

println("Plotting deaths per million for Belgium, Norway and Sweden ...")
plot([dropmissing(df_dth_10m, :Belgium).Belgium, dropmissing(df_dth_10m, :Norway).Norway,
      dropmissing(df_dth_10m, :Sweden).Sweden],
      legend=:outertopright,
      label = ["Belgium" "Norway" "Sweden"],
      ylabel = "Accumulated Deaths",
      xlabel = "Days since first 10 cases",
      title  = "Corona 2020\n Deaths per Million Population")
savefig("figs2/dth_10m_BeNoSe.png")


### WIP:
mR0 = Matrix(df_R0)
# mCint = Matrix(df_Cint)   # Got Strings???
# mClow = [x[1] for x in mCint]
# mChgh = [x[2] for x in mCint]



mClow = Matrix(df_Clow)
mChgh = Matrix(df_Chgh)
i = 4  # Norway
mRx = mR0[:,i]
mCl = mRx-mClow[:,i]
mCh = mChgh[:,i]-mRx
plot(mRx, ribbon=(mCl,mCh))


#
# plot([first.(mCint[:,4]),last.(mCint[:,4])])           # 4:Norway
# plot([[x[2] for x in mCint],[x[2] for x in mCint]])    

showframes()


# EOF
