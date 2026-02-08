using Grpc.Core;
using GRPCServer.Protos;

namespace gRPCServer.Services
{
    public class CalculatorService : Calculator.CalculatorBase
    {
        public override Task<CalcResponse> Sum(CalcRequest request, ServerCallContext context)
        {
            return Task.FromResult(new CalcResponse { Result = request.X + request.Y });
        }

        public override Task<CalcResponse> Sub(CalcRequest request, ServerCallContext context)
        {
            return Task.FromResult(new CalcResponse { Result = request.X - request.Y });
        }

        public override Task<CalcResponse> Mul(CalcRequest request, ServerCallContext context)
        {
            return Task.FromResult(new CalcResponse { Result = request.X * request.Y });
        }

        public override Task<CalcResponse> Div(CalcRequest request, ServerCallContext context)
        {
            if (request.Y == 0)
            {
                throw new RpcException(new Status(StatusCode.InvalidArgument, "Division by zero is not allowed."));
            }
            return Task.FromResult(new CalcResponse { Result = request.X / request.Y });
        }

        public override Task<FactResponse> Fact(FactRequest request, ServerCallContext context)
        {
            if (request.X < 0)
            {
                throw new RpcException(new Status(StatusCode.InvalidArgument, "Factorial is not defined for negative numbers."));
            }
            try
            {
                checked
                {
                    int result = 1;
                    for (int i = 2; i <= request.X; i++)
                    {
                        result *= i;
                    }
                    return Task.FromResult(new FactResponse { Result = result });
                }
            }
            catch (OverflowException)
            {
                throw new RpcException(new Status(StatusCode.InvalidArgument, "Factorial result exceeds int limit."));
            }
        }
    }
}