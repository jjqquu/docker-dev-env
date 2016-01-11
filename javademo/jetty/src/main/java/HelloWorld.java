import com.xiaomi.jinping.PeopleModule;
import org.apache.log4j.Logger;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.DefaultServlet;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.util.EnumSet;

import com.google.inject.Guice;
import com.google.inject.Stage;
import com.google.inject.servlet.GuiceFilter;

//import org.kohsuke.args4j.Argument;
import org.kohsuke.args4j.CmdLineException;
import org.kohsuke.args4j.CmdLineParser;
import org.kohsuke.args4j.Option;


class MyArgument
{
    @Option(name = "-p", usage = "port to which the jetty embed http server listens", metaVar="INT")
    public int port = 30;

    // receives other command line parameters than options
    // @Argument
    // public List<String> arguments = new ArrayList<String>();
}

/**
 * Created by qujinping on 15/12/24.
 *
 *    curl -X DELETE http://localhost:5000/people/1
 *    curl -X POST -H "content-type: applOSTation/json" -d '{"name":"qjp1", "age": 100}' http://localhost:5000/people
 *    curl -X PUT -H "content-type: application/json" -d '{"name":"qjp1", "age": 100}' http://localhost:5000/people
 *    curl -X GET http://localhost:5000/people/qjpname
 *    curl -X GET http://localhost:5000/people?text=blabla
 */
public class HelloWorld {

    public static void main(String[] args) throws Exception {

        Logger logger = Logger.getLogger(HelloWorld.class.getName());

        MyArgument va = new MyArgument();
        CmdLineParser parser = new CmdLineParser(va);

        try {
            // parse the arguments.
            parser.parseArgument(args);

            // arguments.isEmpty() )

        } catch( CmdLineException e ) {
            logger.error(e.getMessage());

            // print the list of available options
            OutputStream promptMsgBuf = new ByteArrayOutputStream();
            parser.printUsage(promptMsgBuf);
            logger.error(promptMsgBuf.toString());

            return;
        }

        Guice.createInjector(
                Stage.PRODUCTION,
                new PeopleModule()
        );

        Server server = new Server(va.port);

        ServletContextHandler context = new ServletContextHandler(server, "/", ServletContextHandler.SESSIONS);
        context.addFilter(GuiceFilter.class, "/*", EnumSet.<javax.servlet.DispatcherType>of(javax.servlet.DispatcherType.REQUEST, javax.servlet.DispatcherType.ASYNC));
        context.addServlet(DefaultServlet.class, "/*");

        logger.info("HelloWorld started");

        server.start();

        server.join();
    }
}
