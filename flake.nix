{
	inputs = { } ;
	outputs =
		{ self } :
			{
				init ? "" ,
				config ? { } ,
				hooks ? { } ,
				nixpkgs ,
				remotes ? { } ,
				system
			} @primary :
				{
					lib.implementation =
						let
							application =
								pkgs.writeShellApplication
									{
										name = "application" ;
										runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
										text =
											let
												config-mapper = name : value : ''git config "${ name }" ${ value }"'' ;
												hook-mapper = name : value : ''ln --symbolic "${ value }" ".git/hooks/${ name }"'' ;
												remote-mapper = name : value : ''git remote add "${ name }" "${ value }"'' ;
												token = "/tmp/resources/${ builtins.hashString "sha512" ( builtins.toJSON primary ) }" ;
												in
													''
														if [ -d ${ token } ]
														then
															mkdir --parents ${ token }
															cd ${ token }
															git init
															${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs config-mapper config ) ) }
														fi
														echo ${ token }
													'' ;
									} ;
							pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
							in "${ application }/bin/application" ;
				} ;
}
