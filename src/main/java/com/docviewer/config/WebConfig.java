package com.docviewer.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

/**
 * Spring MVC configuration for JSP views.
 *
 * JSP files live in /WEB-INF/ and are served by Tomcat Jasper.
 * JSP tag files (*.tag) in /WEB-INF/tags/ are auto-discovered.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Bean
    public InternalResourceViewResolver viewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setPrefix("/WEB-INF/");
        resolver.setSuffix(".jsp");
        resolver.setViewClass(JstlView.class);
        resolver.setOrder(1);
        return resolver;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Static resources (CSS, JS, images) from /static/
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
        // Sample documents
        registry.addResourceHandler("/samples/**")
                .addResourceLocations("file:samples/");
    }
}
