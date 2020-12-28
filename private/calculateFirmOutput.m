function data = calculateFirmOutput(data, globals)
    data.lnOutput = globals.beta0 + globals.betaL * data.lnLabor + ...
        globals.betaK * data.lnKapital + data.omegaT + data.epsilon;
end