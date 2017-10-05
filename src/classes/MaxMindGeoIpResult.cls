public class MaxMindGeoIpResult {

    public City city {get; set;}
    public Continent continent {get; set;}
    public Country country {get; set;}
    public Location location {get; set;}
    public Maxmind maxmind {get; set;}
    public Postal postal {get; set;}
    public RegisteredCountry registered_country {get; set;}
    public List<Subdivisions> subdivisions {get; set;}
    public Traits traits {get; set;}

    public class City {
        public Integer confidence {get; set;}
        public Integer geoname_id {get; set;}
        public Names names {get; set;}
    }

    public class Continent {
        public String code {get; set;}
        public Integer geoname_id {get; set;}
        public Names names {get; set;}
    }

    public class Country {
        public Integer confidence {get; set;}
        public String iso_code {get; set;}
        public Integer geoname_id {get; set;}
        public Names names {get; set;}
    }

    public class Location {
        public Integer average_income {get; set;}
        public Integer population_density {get; set;}
        public Integer accuracy_radius {get; set;}
        public Double latitude {get; set;}
        public Double longitude {get; set;}
        public Integer metro_code {get; set;}
        public String time_zone {get; set;}
    }

    public class Maxmind {
        public Integer queries_remaining {get; set;}
    }

    public class Postal {
        public Integer confidence {get; set;}
        public String code {get; set;}
    }

    public class RegisteredCountry {
        public String iso_code {get; set;}
        public Integer geoname_id {get; set;}
        public Names names {get; set;}
    }

    public class Subdivisions {
        public Integer confidence {get; set;}
        public String iso_code {get; set;}
        public Integer geoname_id {get; set;}
        public Names names {get; set;}
    }

    public class Traits {
        public String user_type {get; set;}
        public Integer autonomous_system_number {get; set;}
        public String autonomous_system_organization {get; set;}
        public String domain {get; set;}
        public String isp {get; set;}
        public String organization {get; set;}
        public String ip_address {get; set;}
    }

    public class Names {
        public String es {get; set;}
        public String fr {get; set;}
        public String ja {get; set;}
        public String pt_BR {get; set;}
        public String ru {get; set;}
        public String zh_CN {get; set;}
        public String de {get; set;}
        public String en {get; set;}
    }

    public String rawRequest {get; set;}

    public String rawResponse {get; set;}

    public String errorMessage {get; set;}
}