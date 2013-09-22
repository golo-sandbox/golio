import fr.insalyon.citi.golo.compiler.GoloCompilationException;
import golo.tools.ScriptsLoader;

import java.io.File;

public class Main {

    public static void main(final String[] args) throws Exception {

        if(args.length > 0 ) {
            //String appDirectory = (new File(".")).getCanonicalPath();
            String appDirectory = "golio.conf";

            File conf = new File(appDirectory+"/conf.golo");
            
            /* Instance of a golo script loader */
            //final ScriptsLoader scriptsLoader = new ScriptsLoader(appDirectory);
            final ScriptsLoader scriptsLoader = new ScriptsLoader((new File(appDirectory)).getAbsolutePath());

            /* load embedded golo resources*/
            scriptsLoader.loadGoloResource("golo/resources/libs/champollion/","ext.champollion.golo");
            scriptsLoader.loadGoloResource("golo/resources/libs/","ext.bozzo.golo");
            scriptsLoader.loadGoloResource("golo/resources/libs/","ext.http.golo");

            scriptsLoader.loadGoloResource("golo/resources/","ext.main.golo");



            if(conf.exists()) {
                /* Load all external golo scripts (in app directory) */
                scriptsLoader.loadAll();
                /* run initialize() in /conf.golo */
                try {
                    scriptsLoader.module("/conf.golo")
                            .method("initialize", Object.class)
                            .run((Object) args[0]);
                } catch (GoloCompilationException g) {
                    System.out.println(g.getProblems());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }


            /* run go() in golo/resources/main.golo */
            try {
                scriptsLoader.module("ext.main.golo")
                        .method("go", Object.class)
                        .run((Object) args[0]);
            } catch (GoloCompilationException g) {
                System.out.println(g.getProblems());
            } catch (Exception e) {
                e.printStackTrace();
            }

            if(conf.exists()) {
                /* run terminate() in /conf.golo */
                Runtime.getRuntime().addShutdownHook(new Thread(){
                    public void run() {
                        try {
                            scriptsLoader.module("/conf.golo")
                                    .method("terminate", Object.class)
                                    .run((Object) args[0]);
                        } catch (GoloCompilationException g) {
                            System.out.println(g.getProblems());
                        }  catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
            }
            
        } else {
            System.out.println("Oh! Oh! Huston, we've got a problem! I think you forgot an argument ...");    
        }



    }

}
