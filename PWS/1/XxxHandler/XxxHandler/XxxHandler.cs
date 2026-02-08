using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;

namespace XxxHandler
{
    public class XxxHandler : IHttpHandler, IRequiresSessionState
    {
        private static int _result;

        public bool IsReusable => true;

        public void ProcessRequest(HttpContext context)
        {
            HttpRequest req = context.Request;
            HttpResponse res = context.Response;
            HttpSessionState session = context.Session;

            Stack<int> stack = session["Stack"] as Stack<int>;
            if (stack == null)
            {
                stack = new Stack<int>();
                session["Stack"] = stack;
            }

            switch (req.HttpMethod)
            {
                case "GET":
                    {
                        int result = _result;
                        if (stack.Count > 0)
                            result += stack.Peek();

                        res.ContentType = "application/json";
                        res.Write("{\"result\": " + result + "}");
                        break;
                    }

                case "POST":
                    {
                        if (!int.TryParse(req.QueryString["result"], out int resultParameter))
                        {
                            res.StatusCode = 400;
                            res.Write("Invalid parameter format");
                            break;
                        }
                        _result = resultParameter;
                        res.Write("Result updated");
                        break;
                    }

                case "PUT":
                    {
                        if (!int.TryParse(req.QueryString["add"], out int addParameter))
                        {
                            res.StatusCode = 400;
                            res.Write("Invalid parameter format");
                            break;
                        }
                        stack.Push(addParameter);
                        res.Write("Added to stack");
                        break;
                    }

                case "DELETE":
                    {
                        if (stack.Count <= 0)
                        {
                            res.StatusCode = 400;
                            res.Write("Stack is empty");
                            break;
                        }
                        stack.Pop();
                        res.Write("Removed from stack");
                        break;
                    }

                default:
                    res.StatusCode = 405;
                    res.Write("Method is not allowed.");
                    break;
            }
        }
    }
}