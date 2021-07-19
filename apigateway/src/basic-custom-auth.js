exports.handler = (event, context, callback) => {
    const token = event.authorizationToken;
    // use token, validate, parse it. etc.
    if (token.toLowerCase() == 'allow'){
        const policy = genPolicy('Allow', event.methodArn);
        const PrincipalId = 'user';
        const context = {
            simpĺeAuth: true
        };
        const response = {
            principalId: PrincipalId,
            policyDocument: policy,
            context: context
        };
        callback(null, response);
    } else {
        callback('Unauthorized')
    }
};

function genPolicy(effect, resource){
    const policy = {}
    policy.Version = '2012-10-17';
    policy.Statement = [];
    const stmt = {};
    stmt.Action = 'execute-api:Invoke';
    stmt.Effect = effect;
    stmt.Resource = resource;
    policy.Statement.push(stmt);
    return policy;
}